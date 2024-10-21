import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/components/default_alert_dialog.dart';
import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/common/components/default_text_field_dialog.dart';
import 'package:gather_here/common/provider/member_info_provider.dart';
import 'package:gather_here/common/utils/utils.dart';
import 'package:gather_here/screen/developer/developer_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../common/const/colors.dart';
import '../../common/storage/storage.dart';
import 'my_page_provider.dart';

class MyPageScreen extends ConsumerWidget {
  static String get name => 'my_page';

  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberState = ref.watch(memberInfoProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (memberState.message != null) {
        Utils.showSnackBar(context, memberState.message!);
      }
    });

    return DefaultLayout(
      title: '마이 페이지',
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _ProfileHeader(),
                  const SizedBox(height: 24),
                  _SettingList(),
                ],
              ),
            ),
            // 로딩 중일 때 반투명 배경과 로딩바를 화면에 띄움
            if (memberState.isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.main,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _profileImage(context, ref),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _userName(context, ref),
            _userPhoneNumber(ref),
          ],
        )
      ],
    );
  }

  Widget _profileImage(BuildContext context, WidgetRef ref) {
    final memberState = ref.watch(memberInfoProvider);
    return GestureDetector(
      onTap: () async {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          final file = File(pickedFile.path);
          ref.read(memberInfoProvider.notifier).compressedFile(file);
        }
      },
      child: Stack(
        children: [
          if (memberState.memberInfoModel?.profileImageUrl != null)
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: memberState.memberInfoModel!.profileImageUrl!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.account_circle),
              ),
            ),
          if (memberState.memberInfoModel?.profileImageUrl == null)
            const Icon(Icons.account_circle, size: 64),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(width: 1)),
              child: const Icon(Icons.edit, size: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userName(BuildContext context, WidgetRef ref) {
    final memberState = ref.watch(memberInfoProvider);

    return Row(
      children: [
        Text(
          memberState.memberInfoModel!.nickname,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return DefaultTextFieldDialog(
                  title: '어떤 닉네임으로 변경할까요?',
                  labels: ['2~20자 이내로 입력해주세요'],
                  onChanged: (nickName) async {
                    await ref
                        .read(memberInfoProvider.notifier)
                        .changeNickName(nickName.last);
                    context.pop();
                  },
                );
              },
            );
          },
          icon: Icon(Icons.edit, size: 18),
        ),
      ],
    );
  }

  Widget _userPhoneNumber(WidgetRef ref) {
    final memberState = ref.watch(memberInfoProvider);

    return Text(
      memberState.memberInfoModel!.identity,
      style: const TextStyle(
        fontSize: 16,
        color: AppColor.grey1,
      ),
    );
  }
}

class _SettingList extends ConsumerWidget {
  const _SettingList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageState = ref.watch(storageKeyProvider);

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          _settingRow(
              title: '비밀번호 변경',
              icon: Icons.key,
              onTap: () => _changePassword(context, ref)),
          const SizedBox(height: 16),
          _settingRow(
              title: '로그아웃',
              icon: Icons.logout,
              onTap: () => ref.read(myPageProvider.notifier).logout()),
          const SizedBox(height: 16),
          _settingRow(
              title: '회원탈퇴',
              icon: Icons.cancel,
              onTap: () => _withDrawl(context, ref)),
          const SizedBox(height: 16),
          _settingRow(title: '서비스 이용약관', icon: Icons.description, indicator: true, onTap: () {
            launchUrlString('https://placid-sneeze-769.notion.site/11f29e9854d48036a272c3cbb59d9e62');
          }),
          const SizedBox(height: 16),
          _settingRow(title: '개발자 정보', icon: Icons.developer_board, indicator: true, onTap: () {
            context.pushNamed(DeveloperScreen.name);
          }),
          const SizedBox(height: 16),
          _settingRow(
              title: '버전정보',
              icon: Icons.info,
              subTitle: storageState.appInfo.toString()),
        ],
      ),
    );
  }

  void _changePassword(BuildContext context, WidgetRef ref) {
    final storageState = ref.watch(storageKeyProvider);

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
          hideText: true,
          onChanged: (textList) async {
            final currentPw = textList[0];
            final changePw = textList[1];
            final changePwConfirm = textList[2];

            if (currentPw.isEmpty ||
                changePw.isEmpty ||
                changePwConfirm.isEmpty) {
              Utils.showSnackBar(context, '빈칸을 채워주세요');
            } else if (changePw.length < 4 || changePwConfirm.length < 4) {
              Utils.showSnackBar(context, '비밀번호는 4자리 이상으로 설정해 주세요');
            } else if (storageState.passWd != currentPw) {
              Utils.showSnackBar(context, '현재 비밀번호가 맞지 않습니다');
            } else if (changePw != changePwConfirm) {
              Utils.showSnackBar(context, '바꿀 비밀번호가 일치하지 않습니다');
            } else {
              await ref.read(memberInfoProvider.notifier).changePassWord(changePw);
              await ref
                  .read(storageKeyProvider.notifier)
                  .updatePassWd(changePw);
              context.pop();
            }
          },
        );
      },
    );
  }

  void _withDrawl(BuildContext context, WidgetRef ref) {
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
  }

  Widget _settingRow({
    required String title,
    required IconData icon,
    String? subTitle,
    bool indicator = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColor.grey5,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24)),
          const SizedBox(width: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  color: AppColor.black2,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          if (subTitle != null)
            Text(subTitle,
                style: const TextStyle(fontSize: 16, color: AppColor.black2)),
          if (indicator) const Icon(Icons.chevron_right)
        ],
      ),
    );
  }
}