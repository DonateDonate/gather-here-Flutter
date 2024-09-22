import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/components/default_alert_dialog.dart';
import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/common/components/default_text_field_dialog.dart';
import 'package:gather_here/common/provider/member_info_provider.dart';
import 'package:gather_here/common/utils/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/const/colors.dart';
import '../../common/storage/storage.dart';
import '../login/login_screen.dart';
import 'my_page_provider.dart';

class MyPageScreen extends StatelessWidget {
  static String get name => 'my_page';

  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '마이 페이지',
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              _ProfileWidget(),
              SizedBox(height: 52),
              _MenuContainerWidget(),
              // _logoutWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileWidget extends ConsumerWidget {
  const _ProfileWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberInfoState = ref.watch(memberInfoProvider);
    ref.listen<MyPageState>(myPageProvider, (previous, current) {
      if(current.changeNickName == 0 || current.changePassWord == 0) {
        ref.read(memberInfoProvider.notifier).getMyInfo();
      }
      _handleStateChanges(context, current);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);

              if (pickedFile != null) {
                // 선택한 이미지의 파일 경로를 참조하여 파일 원본에 접근할 수 있는 객체 생성
                final file = File(pickedFile.path);
                final result = await ref
                    .read(memberInfoProvider.notifier)
                    .changeProfileImage(file);
                final message =
                    result ? '프로필 사진이 업데이트 되었습니다.' : '프로필 사진 업데이트에 실패하였습니다.';
                Utils.showSnackBar(context, message);
              }
            },
            child: Stack(
              children: [
                memberInfoState.memberInfoModel?.profileImageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          memberInfoState.memberInfoModel!.profileImageUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.account_circle,
                        size: 64,
                      ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DefaultTextFieldDialog(
                        title: '어떤 닉네임으로 변경할까요?',
                        labels: ['2~20자 이내로 입력해주세요'],
                        onChanged: (nickName) async {
                          await ref
                              .read(myPageProvider.notifier)
                              .changeNickName(nickName.last);
                        },
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    Text(
                      memberInfoState.memberInfoModel!.nickname,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.edit,
                      size: 18,
                    )
                  ],
                ),
              ),
              Text(
                memberInfoState.memberInfoModel!.identity,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColor.grey1,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _MenuContainerWidget extends ConsumerWidget {
  const _MenuContainerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersion = ref.watch(appVersionProvider);
    final myPageState = ref.watch(myPageProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DefaultTextFieldDialog(
                    title: '비밀번호 변경',
                    labels: const [
                      '기존 비밀번호 입력',
                      '새 비밀번호 입력',
                      '새 비밀번호 확인',
                    ],
                    onChanged: (textList) async {
                      final currentPw = textList[0];
                      final changePw = textList[1];
                      final changePwConfirm = textList[2];
                      if (currentPw.isNotEmpty &&
                          (changePw == changePwConfirm)) {
                        await ref
                            .read(myPageProvider.notifier)
                            .changePassWord(changePw);
                      }
                    },
                  );
                },
              );
            },
            child: const _MenuWidget(
              icon: Icons.key,
              text: '비밀번호 변경',
            ),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DefaultAlertDialog(
                    title: '정말 회원탈퇴 할까요?',
                    content: '다시 되돌릴 수 없어요 :(',
                    onTabConfirm: () async {
                      await ref.read(myPageProvider.notifier).deleteMember();
                    },
                  );
                },
              );
            },
            child: const _MenuWidget(
              icon: Icons.output,
              text: '회원 탈퇴',
            ),
          ),
          appVersion.when(
            data: (appVersion) => _MenuWidget(
              icon: Icons.info,
              text: '버전정보',
              versionInfo: appVersion,
            ),
            error: (error, stackTrace) => const _MenuWidget(
              icon: Icons.info,
              text: '버전정보',
              versionInfo: 'x.x.x',
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? versionInfo;

  const _MenuWidget({
    required this.icon,
    required this.text,
    this.versionInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColor.grey5,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
                fontSize: 16,
                color: AppColor.black2,
                fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          if (versionInfo != null)
            Text(
              versionInfo!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColor.black2,
              ),
            )
        ],
      ),
    );
  }
}

class _logoutWidget extends StatelessWidget {
  const _logoutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: 85,
          height: 40,
          decoration: BoxDecoration(
            color: AppColor.grey3,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              '로그아웃',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColor.black2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _handleStateChanges(BuildContext context, MyPageState state) {
  if (state.changeNickName != null) {
    final message = state.changeNickName == 0
        ? '닉네임 변경에 성공하였습니다.'
        : '닉네임 변경에 실패하였습니다.';
    Utils.showSnackBar(context, message);
  }

  if (state.changePassWord != null) {
    final message = state.changePassWord == 0
        ? '비밀번호가 변경되었습니다.'
        : '비밀번호 변경에 실패하였습니다.';
    Utils.showSnackBar(context, message);
  }

  if (state.deleteMember != null) {
    if (state.deleteMember == 0) {
      context.goNamed(LoginScreen.name);
    } else {
      Utils.showSnackBar(context, '회원탈퇴에 실패했어요');
    }
  }
}