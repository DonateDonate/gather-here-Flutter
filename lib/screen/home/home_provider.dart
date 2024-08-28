import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/model/search_response_model.dart';

import 'package:gather_here/common/repository/map_repository.dart';

class HomeState {
  String? query; // 검색어
  double? lat; // 위도
  double? lon; // 경도
  List<SearchDocumentsModel> results;
  SearchDocumentsModel? selectedResult;

  HomeState({
    this.query,
    this.lat,
    this.lon,
    this.results = const [],
    this.selectedResult,
  });
}

final homeProvider = AutoDisposeStateNotifierProvider<HomeProvider, HomeState>((ref) {
  final repo = ref.watch(mapRepositoryProvider);
  return HomeProvider(repo: repo);
});

class HomeProvider extends StateNotifier<HomeState> {
  final MapRepository repo;

  HomeProvider({
    required this.repo,
  }) : super(HomeState());

  void _setState() {
    state = HomeState(query: state.query, lat: state.lat, lon: state.lon, results: state.results, selectedResult: state.selectedResult);
  }
  void queryChanged({required String value}) async {
    state.query = value;
    _setState();

    state.lat = 37.413294;
    state.lon = 126.734086;

    // 현재좌표와, 쿼리가 있다면 검색하기
    if (state.query != null && state.query!.isNotEmpty && state.lat != null && state.lon != null) {
      final result = await repo.getSearchResults(query: state.query!, x: state.lon!, y: state.lat!);
      state.results = result.documents ?? [];
      _setState();
      print('result: ${state.results.length}');
    }
  }

  void tapSearchResult({required SearchDocumentsModel model}) {
    state.selectedResult = model;
    _setState();
  }
}
