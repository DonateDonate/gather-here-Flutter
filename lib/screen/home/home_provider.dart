import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gather_here/common/location/location_manager.dart';
import 'package:gather_here/common/model/request/room_create_model.dart';
import 'package:gather_here/common/model/request/room_join_model.dart';
import 'package:gather_here/common/model/response/search_response_model.dart';
import 'package:gather_here/common/repository/app_info_repository.dart';
import 'package:gather_here/common/repository/map_repository.dart';
import 'package:gather_here/common/repository/room_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../common/model/response/room_response_model.dart';
import '../../common/storage/storage.dart';
import 'custom_marker.dart';

class HomeState {
  String? query; // 검색어
  double? lat; // 위도
  double? lon; // 경도
  List<SearchDocumentsModel> results; // 장소 검색 결과
  SearchDocumentsModel? selectedResult; // 선택한 장소
  String? inviteCode; // 초대코드

  DateTime? targetDate;
  TimeOfDay? targetTime;

  HomeState({
    this.query,
    this.lat,
    this.lon,
    this.results = const [],
    this.selectedResult,
    this.inviteCode,
    this.targetDate,
    this.targetTime,
  });
}

final homeProvider =
    AutoDisposeStateNotifierProvider<HomeProvider, HomeState>((ref) {
  final mapRepo = ref.watch(mapRepositoryProvider);
  final roomRepo = ref.watch(roomRepositoryProvider);
  final appInfoRepo = ref.watch(appInfoRepositoryProvider);
  final locationManager = ref.watch(locationManagerProvider);
  final storage = ref.watch(storageProvider);

  return HomeProvider(
    mapRepo: mapRepo,
    roomRepo: roomRepo,
    appInfoRepo: appInfoRepo,
    locationManager: locationManager,
    storage: storage,
  );
});

class HomeProvider extends StateNotifier<HomeState> {
  final RoomRepository roomRepo;
  final MapRepository mapRepo;
  final AppInfoRepository appInfoRepo;
  final LocationManager locationManager;
  final FlutterSecureStorage storage;

  HomeProvider({
    required this.roomRepo,
    required this.mapRepo,
    required this.appInfoRepo,
    required this.locationManager,
    required this.storage,
  }) : super(HomeState()) {
    getAppInfo();
  }

  void _setState() {
    state = HomeState(
      query: state.query,
      lat: state.lat,
      lon: state.lon,
      results: state.results,
      selectedResult: state.selectedResult,
      inviteCode: state.inviteCode,
      targetDate: state.targetDate,
      targetTime: state.targetTime,
    );
  }

  // 홈화면 들어왔을때 room 정보조회
  Future<RoomResponseModel?> getRoomInfo() async {
    return await roomRepo.getRoom();
  }

  void inviteCodeChanged({required String value}) {
    state.inviteCode = value;
    _setState();
  }

  Future<RoomResponseModel?> tapInviteButton() async {
    if (state.inviteCode?.length != 4) {
      return null;
    }

    try {
      final result = await roomRepo.postJoinRoom(
          body: RoomJoinModel(shareCode: state.inviteCode!));
      return result;
    } catch (err) {
      print('${err.toString()}');
      return null;
    }
  }

  void getAppInfo() async {
    try {
      final result = await appInfoRepo.getAppInfo();
      storage.write(key: StorageKey.appInfo.name, value: result.appVersion);
    } catch (err) {
      debugPrint('앱 정보 가져오기 실패');
    }
  }

  Future<RoomResponseModel?> tapStartSharingButton(
      DateTime targetDate, TimeOfDay targetTime) async {
    state.targetDate = targetDate;
    state.targetTime = targetTime;
    final encounterDate = DateFormat('yyyy-MM-dd HH:mm').format(
      DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        targetTime.hour,
        targetTime.minute,
      ),
    );
    print(encounterDate);

    if (state.targetDate != null &&
        state.targetTime != null &&
        state.selectedResult != null) {
      try {
        final result = await roomRepo.postCreateRoom(
          body: RoomCreateModel(
            destinationLat: double.parse(state.selectedResult!.y),
            destinationLng: double.parse(state.selectedResult!.x),
            destinationName: state.selectedResult?.place_name ?? "",
            encounterDate: encounterDate,
          ),
        );
        print(result.toString());
        return result;
      } catch (err) {
        print(err.toString());
      }
    }

    return null;
  }

  void queryChanged({required String value}) async {
    state.query = value;

    if (value.isEmpty) {
      state.results = [];
      state.selectedResult = null;
    }
    _setState();

    // 현재좌표와, 쿼리가 있다면 검색하기
    if (state.query != null &&
        state.query!.isNotEmpty &&
        state.lat != null &&
        state.lon != null) {
      final result = await mapRepo.getSearchResults(
          query: state.query!, x: state.lon!, y: state.lat!);
      state.results = result.documents ?? [];
      _setState();
    }
  }

  void getCurrentLocation(VoidCallback completion) async {
    final position = await locationManager.getCurrentPosition();
    state.lat = position.latitude;
    state.lon = position.longitude;
    _setState();
    completion();
  }

  // 지도의 마커를 눌렀을 때
  void tapLocationMarker(SearchDocumentsModel model) {
    state.selectedResult = model;
    _setState();
  }

  Future<BitmapDescriptor> createCustomMarkerBitmap(String label) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    const double width = 150;
    const double height = 100;

    CustomMarker(label).paint(canvas, const Size(width, height));

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final ByteData? byteData =
    await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}
