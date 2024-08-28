import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/dio/dio_kakao.dart';
import 'package:gather_here/common/model/search_response_model.dart';
import 'package:retrofit/http.dart';
import 'package:dio/dio.dart';

part 'map_repository.g.dart';

final mapRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioKakaoProvider);
  return MapRepository(dio, baseUrl: 'https://dapi.kakao.com/v2/local/search/keyword');
});

// https://dapi.kakao.com/v2/local/search/keyword
@RestApi()
abstract class MapRepository {
  factory MapRepository(Dio dio, {String baseUrl}) = _MapRepository;

  @GET('')
  Future<SearchResponseModel> getSearchResults({
    @Query('query') required String query,
    @Query('x') required double x,
    @Query('y') required double y,
});
}