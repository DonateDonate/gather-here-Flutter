import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            physics: NeverScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    _TitleHeader(),
                    Spacer(),
                    _TextFields(),
                    SizedBox(height: 40),
                    _LoginButton(),
                    SizedBox(height: 40),
                    _BottomContainer(),
                    SizedBox(height: 10),
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
  const _TitleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            '대충 모여 소개 문구 추천 받습니다',
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
    final vm = ref.watch(loginProvider);

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
        SizedBox(height: 20),
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
  const _LoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(loginProvider);

    return DefaultButton(
      title: '로그인',
      isEnabled: vm.isButtonEnalbed,
      onTap: () async {
        final result = await ref.read(loginProvider.notifier).postLogin();

        if (result) {
          context.goNamed(HomeScreen.name);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('로그인 실패')));
        }
      },
    );
  }
}


class _BottomContainer extends StatelessWidget {
  const _BottomContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(height: 1.5, color: AppColor.grey1),
            ),
            SizedBox(width: 30),
            Text('또는',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(width: 30),
            Expanded(
              child: Container(height: 1.5, color: AppColor.grey1),
            ),
          ],
        ),
        SizedBox(height: 80),
        Text(
          '비밀번호를 잊으셨나요?',
          style: TextStyle(
            fontSize: 16,
            color: AppColor.grey1,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '계정이 없으신가요?',
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
              child: Text(
                '가입하기',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColor.blue,
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
