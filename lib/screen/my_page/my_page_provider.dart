import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gather_here/common/model/request/nickname_model.dart';
import 'package:gather_here/common/model/request/password_model.dart';
import 'package:gather_here/common/model/response/member_info_model.dart';
import 'package:gather_here/common/model/response/profile_image_url_model.dart';
import 'package:gather_here/common/provider/member_info_provider.dart';
import 'package:gather_here/common/repository/member_repository.dart';
import 'package:gather_here/common/storage/storage.dart';

import '../../common/const/const.dart';
import '../../common/dio/dio.dart';
import '../../common/repository/auth_repository.dart';

final myPageProvider = AutoDisposeStateNotifierProvider<MyPageProvider,
    AsyncValue<MemberInfoModel>>((ref) {
  final memberRepository = ref.watch(memberRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final dio = ref.watch(dioProvider);
  final memberInfo = ref.watch(memberInfoProvider.notifier);
  final storage = ref.watch(storageProvider);

  return MyPageProvider(
    memberRepository: memberRepository,
    authRepository: authRepository,
    dio: dio,
    memberInfoProvider: memberInfo,
    storage: storage,
  );
});

class MyPageProvider extends StateNotifier<AsyncValue<MemberInfoModel>> {
  final MemberRepository memberRepository;
  final AuthRepository authRepository;
  final Dio dio;
  final MemberInfoProvider memberInfoProvider;
  final FlutterSecureStorage storage;

  MyPageProvider({
    required this.memberRepository,
    required this.authRepository,
    required this.dio,
    required this.memberInfoProvider,
    required this.storage,
  }) : super(const AsyncValue.loading()) {
    // 초기 상태를 로딩 상태로 설정
    getMyInfo();
  }

  void getMyInfo() async {
    try {
      final memberInfo = await memberInfoProvider.getMyInfo();
      if (memberInfo != null) {
        state = AsyncValue.data(memberInfo);
      } else {
        throw Exception("No member information found");
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }


  Future<bool> changeProfileImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;

      final multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      );

      final formData = FormData.fromMap({
        'imageFile': multipartFile,
      });

      final response = await dio.post(
        '${Const.baseUrl}/members/profile',
        data: formData,
        options: Options(
          headers: {
            'accessToken': 'true',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      if (response.statusCode == 200) {
        final profileImageUrlModel =
            ProfileImageUrlModel.fromJson(response.data);
        debugPrint('url: ${response.data['imageUrl']}');
        state = AsyncValue.data(state.value!
            .copyWith(profileImageUrl: profileImageUrlModel.imageUrl));
        return true;
      } else {
        debugPrint('Server responded with status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('changeProfileImage Err: $e');

      return false;
    }
  }

  Future<bool> changeNickName(String nickName) async {
    try {
      await memberRepository.patchChangeNickName(
          body: NicknameModel(nickname: nickName));
      getMyInfo();
      return true;
    } catch (e) {
      debugPrint('changeNickName Err: $e');
      return false;
    }
  }

  Future<bool> changePassWord(String passWord) async {
    try {
      await memberRepository.patchChangePassWord(
          body: PasswordModel(password: passWord));
      return true;
    } catch (e) {
      debugPrint('changePassWord Err: $e');
      return false;
    }
  }

  Future<bool> deleteMember() async {
    try {
      await authRepository.deleteMember();
      await storage.deleteAll();
      return true;
    } catch (e) {
      debugPrint('deleteMember Err: $e');
      return false;
    }
  }
}
