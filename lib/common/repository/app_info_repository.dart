import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:gather_here/common/const/const.dart';
import 'package:gather_here/common/model/app_info_model.dart';

part 'app_info_repository.g.dart';

final appInfoRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return AppInfoRepository(dio, baseUrl: Const.baseUrl);
});

// http://ec2-13-124-216-179.ap-northeast-2.compute.amazonaws.com:8080
@RestApi()
abstract class AppInfoRepository {
  factory AppInfoRepository(Dio dio, {String baseUrl}) = _AppInfoRepository;

  @GET('/appInfos')
  @Headers({
    'accessToken': 'true',
    'refreshToken': 'true',
  })
  Future<AppInfoModel> getAppInfo();
}