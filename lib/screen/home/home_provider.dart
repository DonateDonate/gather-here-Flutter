import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gather_here/common/location/location_manager.dart';
import 'package:gather_here/common/model/room_create_model.dart';
import 'package:gather_here/common/model/room_join_model.dart';
import 'package:gather_here/common/model/search_response_model.dart';

import 'package:gather_here/common/repository/map_repository.dart';
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
  return HomeProvider(mapRepo: mapRepo, roomRepo: roomRepo);
});

class HomeProvider extends StateNotifier<HomeState> {
  final RoomRepository roomRepo;
  final MapRepository mapRepo;

  HomeProvider({
    required this.roomRepo,
    required this.mapRepo,
  }) : super(HomeState());

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

  void inviteCodeChanged({required String value}) {
    state.inviteCode = value;
    _setState();
  }

  Future<bool> tapInviteButton() async {
    if (state.inviteCode?.length != 4) {
      return false;
    }

    try {
      final result = await roomRepo.postJoinRoom(
          body: RoomJoinModel(shareCode: state.inviteCode!));
      return true;
    } catch (err) {
      print('${err.toString()}');
      return false;
    }
  }

  void tapLocationMarker(SearchDocumentsModel model) {
    state.selectedResult = model;
    _setState();
  }

  Future<bool> tapStartSharingButton() async {
    state.targetDate = DateTime(2024, 08, 30);
    state.targetTime = TimeOfDay(hour: 21, minute: 0);

    if (state.targetDate != null &&
        state.targetTime != null &&
        state.selectedResult != null) {

      try {
        final result = await roomRepo.postCreateRoom(
          body: RoomCreateModel(
            destinationLat: double.parse(state.selectedResult!.y),
            destinationLng: double.parse(state.selectedResult!.x),
            destinationName: state.selectedResult?.place_name ?? "",
            encounterDate: "2024-08-29 22:00",
          ),
        );
        print(result.toString());
        return true;
      } catch(err) {
        print(err.toString());
      }
    }

    return false;
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
      print('result: ${state.results.length}');
    }
  }

  void getCurrentLocation() async {
    final position = await LocationManager.getCurrentPosition();
    state.lat = position.latitude;
    state.lon = position.longitude;
    _setState();
  }

  void tapSearchResult({required SearchDocumentsModel model}) {
    state.selectedResult = model;
    _setState();
  }
}
