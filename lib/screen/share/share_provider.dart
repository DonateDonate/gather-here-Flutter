import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/screen/share/image_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:gather_here/common/location/location_manager.dart';
import 'package:gather_here/common/model/request/room_exit_model.dart';
import 'package:gather_here/common/model/response/room_response_model.dart';
import 'package:gather_here/common/model/socket_request_model.dart';
import 'package:gather_here/common/model/socket_response_model.dart';
import 'package:gather_here/common/repository/room_repository.dart';
import 'package:gather_here/common/router/router.dart';
import 'package:gather_here/screen/share/socket_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShareState {
  double? myLat; // 위도
  double? myLong; // 경도
  double? distance; // 거리
  RoomResponseModel? roomModel;
  String? isHost;

  List<SocketMemberListModel> members;
  List<Marker?> markers;
  int remainSeconds;
  bool isTracking;
  bool isSocketClosed;

  ShareState({
    this.myLat,
    this.myLong,
    this.distance,
    this.roomModel,
    this.isHost,
    required this.members,
    required this.markers,
    this.remainSeconds = 0,
    required this.isTracking,
    this.isSocketClosed = false,
  });
}

final shareProvider = AutoDisposeStateNotifierProvider<ShareProvider, ShareState>((ref) {
  final socketManage = ref.watch(socketManagerProvider);
  final roomRepo = ref.watch(roomRepositoryProvider);
  final locationManager = ref.watch(locationManagerProvider);
  final router = ref.watch(routerProvider);

  return ShareProvider(
    roomRepository: roomRepo,
    socketManager: socketManage,
    locationManager: locationManager,
    router: router,
  );
});

class ShareProvider extends StateNotifier<ShareState> {
  final RoomRepository roomRepository;
  final SocketManager socketManager;
  final LocationManager locationManager;
  final GoRouter router;

  late final StreamSubscription<Position?> _positionStream;

  ShareProvider({
    required this.roomRepository,
    required this.socketManager,
    required this.locationManager,
    required this.router,
  }) : super(ShareState(members: [], markers: [], isTracking: true));

  void _setState() {
    state = ShareState(
      isHost: state.isHost,
      myLat: state.myLat,
      myLong: state.myLong,
      distance: state.distance,
      roomModel: state.roomModel,
      members: state.members,
      markers: state.markers,
      remainSeconds: state.remainSeconds,
      isTracking: state.isTracking,
    );
  }

  // 초기값 설정
  Future<void> setInitState(String isHost, RoomResponseModel roomModel) async {
    state.isHost = isHost;
    state.roomModel = roomModel;
    final position = await locationManager.getCurrentPosition();
    state.myLat = position.latitude;
    state.myLong = position.longitude;

    // 남은 시간 계산 및 할당
    final parsedDate = DateTime.parse(roomModel.encounterDate!);
    final difference = parsedDate.difference(DateTime.now());

    state.remainSeconds = difference.inSeconds >= 0 ? difference.inSeconds : 0;
    _setState();
  }

  // 소켓 최초연결 (type 0: create, type1: join, type2: event)
  Future<void> connectSocket({required int type}) async {
    await socketManager.connect();
    state.isSocketClosed = true;

    final distance = locationManager.calculateDistance(
      state.myLat!,
      state.myLong!,
      state.roomModel!.destinationLat!,
      state.roomModel!.destinationLng!,
    );
    state.distance = distance;
    _setState();

    deliveryMyInfo(type);

    socketManager.observeConnection().listen(
      (position) async {
        Map<String, dynamic> resultMap = jsonDecode(position);
        final results = SocketResponseModel.fromJson(resultMap);

        state.members = results.memberLocationResList;
        state.members.sort((e1, e2) => e1.destinationDistance.compareTo(e2.destinationDistance));

        final markers = await Future.wait(
          results.memberLocationResList.map(
            (result) async {
              final marker = await ImageMarker.buildMarkerFromUrl(
                id: result.memberSeq.toString(),
                url: result.imageUrl == "" ? 'http://www.gravatar.com/avatar/?d=mp' : result.imageUrl,
                position: LatLng(result.presentLat, result.presentLng),
                nickname: result.nickname,
                width: 100,
              );
              return marker;
            },
          ),
        );

        state.markers = markers;

        for (int i = 0; i < state.members.length; i++) {
          state.members[i].rank = i+1;
        }

        _setState();
      },
      onDone: () async {
        if (state.isSocketClosed) { return; }

        final result = await roomRepository.getRoom();
        // room api 조회후, 방이 남아 있다면 다시 연결 해주기
        if (result.roomSeq != null) {
          await connectSocket(type: 1);
        }
        // 종료일 땐 방 나가기
        else {
          _positionStream.cancel();
          router.pop();
        }
      },
    );
  }

  // 소켓연결만 종료
  void disconnectOnlySocket() async {
    state.isSocketClosed = true;
    await socketManager.close();
  }

  // 소켓연결종료
  void disconnectSocket() async {
    if (state.roomModel?.roomSeq != null) {
      await roomRepository.postExitRoom(body: RoomExitModel(roomSeq: state.roomModel!.roomSeq!));
      await socketManager.close();
    }
  }

  // 소켓 통신
  void deliveryMyInfo(int type) {
    socketManager.deliveryMyInfo(
      SocketRequestModel(
          type: type, presentLat: state.myLat!, presentLng: state.myLong!, destinationDistance: state.distance!),
    );
  }

  // 내 현재 위치 설정
  void setPosition(double lat, double long) {
    state.myLat = lat;
    state.myLong = long;
    final distance = locationManager.calculateDistance(
      state.myLat!,
      state.myLong!,
      state.roomModel!.destinationLat!,
      state.roomModel!.destinationLng!,
    );
    state.distance = distance;
    _setState();
  }

  // 위치정보 구독하기
  void observeMyLocation(void Function(double, double) callback) {
    _positionStream = locationManager.observePosition().listen(
      (position) {
        if (position != null) {
          setPosition(position.latitude, position.longitude);
          deliveryMyInfo(2);
          callback(position.latitude, position.longitude);
        }
      },
    );
  }

  // 타이머 ++
  void timeTick() {
    if (state.remainSeconds <= 0) {
      return;
    }
    state.remainSeconds -= 1;
    _setState();
  }

  // 내 위치 추적 버튼 toggle
  void toggleTrackingButton() {
    state.isTracking = !state.isTracking;
    _setState();
  }
}
