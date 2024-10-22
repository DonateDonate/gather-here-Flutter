import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/model/request/nickname_model.dart';
import 'package:gather_here/common/model/response/member_info_model.dart';
import 'package:gather_here/common/repository/member_repository.dart';

import '../const/const.dart';
import '../dio/dio.dart';
import '../model/request/password_model.dart';
import '../model/response/profile_image_url_model.dart';
import '../utils/utils.dart';

class MemberInfoState {
  MemberInfoModel? memberInfoModel;
  String? message;
  bool isLoading;

  MemberInfoState({
    this.memberInfoModel,
    this.message,
    this.isLoading = false,
  });
}

final memberInfoProvider =
    AutoDisposeStateNotifierProvider<MemberInfoProvider, MemberInfoState>(
        (ref) {
  final memberRepository = ref.watch(memberRepositoryProvider);
  final dio = ref.watch(dioProvider);

  return MemberInfoProvider(
    memberRepository: memberRepository,
    dio: dio,
  );
});

class MemberInfoProvider extends StateNotifier<MemberInfoState> {
  final MemberRepository memberRepository;
  final Dio dio;

  MemberInfoProvider({
    required this.memberRepository,
    required this.dio,
  }) : super(MemberInfoState()) {
    getMyInfo();
  }

  void _setState() async {
    state = MemberInfoState(
        memberInfoModel: state.memberInfoModel, message: state.message, isLoading: state.isLoading);
    await Future.delayed(const Duration(seconds: 1));
    state =
        MemberInfoState(memberInfoModel: state.memberInfoModel, message: null, isLoading: state.isLoading);
  }

  Future<void> getMyInfo() async {
    try {
      final memberInfo = await memberRepository.getMemberInfo();
      state.memberInfoModel = memberInfo;
      _setState();
    } catch (e, stackTrace) {
      debugPrint('getMyInfo: $e, $stackTrace');
    }
  }

  Future<void> changeNickName(String nickName) async {
    try {
      await memberRepository.patchChangeNickName(
        body: NicknameModel(nickname: nickName),
      );
      state.message = '닉네임 변경에 성공하였습니다';
      // _setState();
      getMyInfo();
    } catch (e) {
      debugPrint('changeNickName Err: $e');
      state.message = '닉네임 변경에 실패하였습니다.';
      _setState();
    }
  }

  Future<void> changePassWord(String passWord) async {
    try {
      await memberRepository.patchChangePassWord(
        body: PasswordModel(password: passWord),
      );
      state.message = '비밀번호가 변경되었습니다.';
      _setState();
    } catch (e) {
      debugPrint('changePassWord Err: $e');
      state.message = '비밀번호 변경에 실패하였습니다.';
      _setState();
    }
  }

  void compressedFile(File imageFile) async {
    final compressedFile = await Utils.compressImage(imageFile);
    changeProfileImage(compressedFile);
  }

  void changeProfileImage(File imageFile) async {
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

        state.message = '프로필 사진이 업데이트 되었습니다.';
        state.memberInfoModel = state.memberInfoModel
            ?.copyWith(profileImageUrl: profileImageUrlModel.imageUrl);
        _setState();
      } else {
        debugPrint('Server responded with status code: ${response.statusCode}');
        state.message = '프로필 사진 업데이트에 실패하였습니다.';
        _setState();
      }
    } catch (e) {
      state.message = '프로필 사진 업데이트에 실패하였습니다.';
      _setState();

      if (e is DioException) {
        debugPrint('changeProfileImage Dio Error: ${e.message}');
        debugPrint('Response: ${e.response?.data}');
      } else {
        debugPrint('changeProfileImage Unknown Error: $e');
      }
    }
    // setProgressIndicator(false);
  }

   Future<void> setProgressIndicator(bool visible) async {
    state.isLoading = visible;
    _setState();
  }
}
