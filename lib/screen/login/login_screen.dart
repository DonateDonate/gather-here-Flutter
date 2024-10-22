import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/utils/utils.dart';
import 'package:go_router/go_router.dart';

import 'package:gather_here/screen/login/login_provider.dart';
import 'package:gather_here/screen/sign_up/sign_up_screen.dart';
import 'package:gather_here/common/components/default_button.dart';
import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/common/components/default_text_form_field.dart';
import 'package:gather_here/common/const/colors.dart';
import 'package:gather_here/screen/home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  static get name => 'Login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const _TitleHeader(),
                    const Spacer(),
                    _TextFields(),
                    const SizedBox(height: 40),
                    const _LoginButton(),
                    const SizedBox(height: 40),
                    const _BottomContainer(),
                    const SizedBox(height: 10),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleHeader extends StatelessWidget {
  const _TitleHeader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '로그인',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 20),
          Text(
            '목적지까지 함께!\n방을 만들고 친구들과 위치를 공유하세요.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _TextFields extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        DefaultTextFormField(
          title: '아이디',
          label: '휴대폰 번호',
          keyboardType: TextInputType.number,
          onChanged: (text) {
            ref.read(loginProvider.notifier).idValueChanged(value: text);
          },
        ),
        const SizedBox(height: 20),
        DefaultTextFormField(
          title: '비밀번호',
          label: '4 ~ 10자',
          obscureText: true,
          onChanged: (text) {
            ref.read(loginProvider.notifier).pwValueChanged(value: text);
          },
        ),
      ],
    );
  }
}

class _LoginButton extends ConsumerWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(loginProvider);

    return DefaultButton(
      title: '로그인',
      isEnabled: vm.isButtonEnabled,
      onTap: () async {
        final result = await ref.read(loginProvider.notifier).postLogin();

        if (result) {
          context.goNamed(HomeScreen.name);
        } else {
          Utils.showSnackBar(context, '로그인 실패');
        }
      },
    );
  }
}


class _BottomContainer extends StatelessWidget {
  const _BottomContainer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(height: 1.5, color: AppColor.grey1),
            ),
            const SizedBox(width: 30),
            const Text('또는',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(width: 30),
            Expanded(
              child: Container(height: 1.5, color: AppColor.grey1),
            ),
          ],
        ),
        const SizedBox(height: 80),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '아직 계정이 없으신가요?',
              style: TextStyle(
                fontSize: 16,
                color: AppColor.grey1,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              onPressed: () {
                context.goNamed(SignUpScreen.name);
              },
              child: const Text(
                '가입하기',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColor.main,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
