import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gather_here/common/location/location_manager.dart';
import 'package:gather_here/common/model/response/member_info_model.dart';
import 'package:gather_here/common/model/request/room_create_model.dart';
import 'package:gather_here/common/model/request/room_join_model.dart';
import 'package:gather_here/common/model/response/room_response_model.dart';
import 'package:gather_here/common/model/response/search_response_model.dart';
import 'package:gather_here/common/repository/map_repository.dart';
import 'package:gather_here/common/repository/member_repository.dart';
import 'package:gather_here/common/repository/room_repository.dart';

class HomeState {
  String? query; // 검색어
  double? lat; // 위도
  double? lon; // 경도
  List<SearchDocumentsModel> results; // 장소 검색 결과
  SearchDocumentsModel? selectedResult; // 선택한 장소
  String? inviteCode; // 초대코드

  DateTime? targetDate;
  TimeOfDay? targetTime;

  MemberInfoModel? infoModel;

  HomeState({
    this.query,
    this.lat,
    this.lon,
    this.results = const [],
    this.selectedResult,
    this.inviteCode,
    this.targetDate,
    this.targetTime,
    this.infoModel,
  });
}

final homeProvider = AutoDisposeStateNotifierProvider<HomeProvider, HomeState>((ref) {
  final mapRepo = ref.watch(mapRepositoryProvider);
  final roomRepo = ref.watch(roomRepositoryProvider);
  final memberRepo = ref.watch(memberRepositoryProvider);
  final locationManager = ref.watch(locationManagerProvider);

  return HomeProvider(
    mapRepo: mapRepo,
    memberRepo: memberRepo,
    roomRepo: roomRepo,
    locationManager: locationManager,
  );
});

class HomeProvider extends StateNotifier<HomeState> {
  final RoomRepository roomRepo;
  final MapRepository mapRepo;
  final MemberRepository memberRepo;
  final LocationManager locationManager;

  HomeProvider({
    required this.roomRepo,
    required this.mapRepo,
    required this.memberRepo,
    required this.locationManager,
  }) : super(HomeState()) {}

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
      infoModel: state.infoModel,
    );
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
      final result = await roomRepo.postJoinRoom(body: RoomJoinModel(shareCode: state.inviteCode!));
      return result;
    } catch (err) {
      print('${err.toString()}');
      return null;
    }
  }

  void getMyInfo() async {
    try {
      final memberInfo = await memberRepo.getMemberInfo();
      state.infoModel = memberInfo;
      _setState();
    } catch (err) {
      debugPrint('getMyInfo: $err');
    }
  }

  Future<RoomResponseModel?> tapStartSharingButton() async {
    state.targetDate = DateTime(2024, 08, 30);
    state.targetTime = TimeOfDay(hour: 21, minute: 0);

    if (state.targetDate != null && state.targetTime != null && state.selectedResult != null) {
      try {
        final result = await roomRepo.postCreateRoom(
          body: RoomCreateModel(
            destinationLat: double.parse(state.selectedResult!.y),
            destinationLng: double.parse(state.selectedResult!.x),
            destinationName: state.selectedResult?.place_name ?? "",
            encounterDate: "2024-09-30 23:00",
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
    if (state.query != null && state.query!.isNotEmpty && state.lat != null && state.lon != null) {
      final result = await mapRepo.getSearchResults(query: state.query!, x: state.lon!, y: state.lat!);
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
}
