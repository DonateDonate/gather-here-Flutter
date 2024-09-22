import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/model/response/member_info_model.dart';
import 'package:gather_here/common/repository/member_repository.dart';

import '../const/const.dart';
import '../dio/dio.dart';
import '../model/response/profile_image_url_model.dart';

class MemberInfoState {
  MemberInfoModel? memberInfoModel;

  MemberInfoState({
    this.memberInfoModel,
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

  Future<void> getMyInfo() async {
    try {
      final memberInfo = await memberRepository.getMemberInfo();
      state = MemberInfoState(memberInfoModel: memberInfo);
    } catch (e, stackTrace) {
      debugPrint('getMyInfo: $e, $stackTrace');
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
        state = MemberInfoState(
          memberInfoModel: state.memberInfoModel
              ?.copyWith(profileImageUrl: profileImageUrlModel.imageUrl),
        );
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
}
