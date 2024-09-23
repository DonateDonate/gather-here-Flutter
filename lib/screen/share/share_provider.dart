import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/location/location_manager.dart';
import 'package:gather_here/common/model/request/room_exit_model.dart';
import 'package:gather_here/common/model/response/room_response_model.dart';
import 'package:gather_here/common/model/socket_model.dart';
import 'package:gather_here/common/model/socket_response_model.dart';
import 'package:gather_here/common/repository/room_repository.dart';
import 'package:gather_here/screen/share/socket_manager.dart';

class ShareState {
  double? myLat; // 위도
  double? myLong; // 경도
  double? distance; // 경도
  RoomResponseModel? roomModel;
  String? isHost;
  int remainSeconds;

  List<SocketMemberListModel> members;

  ShareState({
    this.myLat,
    this.myLong,
    this.distance,
    this.roomModel,
    this.isHost,
    required this.members,
    this.remainSeconds = 0,
  });
}

final shareProvider = AutoDisposeStateNotifierProvider<ShareProvider, ShareState>((ref) {
  final socketManage = ref.watch(socketManagerProvider);
  final roomRepo = ref.watch(roomRepositoryProvider);
  final locationManager = ref.watch(locationManagerProvider);

  return ShareProvider(
    roomRepository: roomRepo,
    socketManager: socketManage,
    locationManager: locationManager,
  );
});

class ShareProvider extends StateNotifier<ShareState> {
  final RoomRepository roomRepository;
  final SocketManager socketManager;
  final LocationManager locationManager;

  ShareProvider({
    required this.roomRepository,
    required this.socketManager,
    required this.locationManager,
  }) : super(ShareState(members: [])) {}

  void _setState() {
    state = ShareState(
      isHost: state.isHost,
      myLat: state.myLat,
      myLong: state.myLong,
      distance: state.distance,
      roomModel: state.roomModel,
      members: state.members,
      remainSeconds: state.remainSeconds,
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

    final parsedDate = DateTime.parse(roomModel.encounterDate);
    final difference = parsedDate.difference(DateTime.now());

    state.remainSeconds = difference.inSeconds;
    _setState();
  }

  // 소켓과 최초연결
  Future<void> connectSocket() async {
    await socketManager.connect();
    final distance = locationManager.calculateDistance(
      state.myLat!,
      state.myLong!,
      state.roomModel!.destinationLat,
      state.roomModel!.destinationLng,
    );
    state.distance = distance;
    _setState();
    if (state.isHost == 'true') {
      deliveryMyInfo(0);
    } else {
      deliveryMyInfo(1);
    }

    socketManager.observeConnection().listen((position) {
      print('callback: $position');
      // JSON 문자열을 Map으로 변환
      print(position.runtimeType);
      Map<String, dynamic> resultMap = jsonDecode(position);
      final results = SocketResponseModel.fromJson(resultMap);
      // final destination = SocketMemberListModel(
      //   memberSeq: 0,
      //   nickname: '목적지',
      //   imageUrl: '',
      //   presentLat: state.roomModel!.destinationLat,
      //   presentLng: state.roomModel!.destinationLng,
      //   destinationDistance: 0,
      // );
      state.members = results.memberLocationResList;
      print('members: ${results.memberLocationResList.length}');
      _setState();
    });
  }

  // 소켓연결종료
  void disconnectSocket() async {
    if (state.roomModel?.roomSeq != null) {
      await socketManager.close();
      roomRepository.postExitRoom(body: RoomExitModel(roomSeq: state.roomModel!.roomSeq));
    }
  }

  // 소켓 통신
  void deliveryMyInfo(int type) {
    socketManager.deliveryMyInfo(
      SocketModel(
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
      state.roomModel!.destinationLat,
      state.roomModel!.destinationLng,
    );
    state.distance = distance;
    _setState();
  }

  // 위치정보 구독하기
  void observeMyLocation(void Function(double, double) callback) {
    locationManager.observePosition().listen(
      (position) {
        print(position.toString());
        if (position != null) {
          print('my position ${position}');
          setPosition(position.latitude, position.longitude);
          deliveryMyInfo(2);
          callback(position.latitude, position.longitude);
        }
      },
    );
  }

  // 타이머 ++
  void timeTick() {
    if (state.remainSeconds == 0) {
      return;
    }
    state.remainSeconds -= 1;
    _setState();
  }
}
