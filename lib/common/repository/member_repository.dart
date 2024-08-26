import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/const/const.dart';
import 'package:gather_here/common/dio/dio.dart';
import 'package:retrofit/http.dart';

import '../model/response/member_info_model.dart';

part 'member_repository.g.dart';

final memberRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return MemberRepository(dio, baseUrl: Const.baseUrl);
});

@RestApi()
abstract class MemberRepository {
  factory MemberRepository(Dio dio, {String baseUrl}) = _MemberRepository;

  @GET('/members')
  @Headers({
    'accessToken': 'true',
  })
  Future<MemberInfoModel> getMemberInfo();
}