import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/const/const.dart';
import 'package:gather_here/common/dio/dio.dart';
import 'package:gather_here/common/model/request/nickname_model.dart';
import 'package:gather_here/common/model/request/password_model.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

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

  // @POST('/members/profile')
  // @Headers({
  //   'accessToken': 'true',
  //   'Content-Type': 'multipart/form-data',
  // })
  // Future<ProfileImageUrlModel> postProfileImage({
  //   @Part() required MultipartFile image,
  // });

  @PATCH('/members/password')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> patchPassWord({
    @Body() required PasswordModel body,
  });

  @PATCH('/members/nickname')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> patchNickName({
    @Body() required NicknameModel body,
  });
}
