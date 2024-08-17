import 'package:flutter/material.dart';
import 'package:gather_here/common/components/default_button.dart';
import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/common/components/default_text_form_field.dart';

class SignUpScreen extends StatelessWidget {
  static String get name => 'SignUp';

  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '회원가입',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TextFields(),
                    Spacer(),
                    DefaultButton(title: '회원가입', onTap: () {}),
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

class _TextFields extends StatelessWidget {
  const _TextFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultTextFormField(
          title: '아이디',
          label: '휴대폰 번호',
          onChanged: (value) {},
        ),
        SizedBox(height: 20),
        DefaultTextFormField(
          title: '비밀번호',
          label: '4 ~ 10자',
          onChanged: (value) {},
        ),
        SizedBox(height: 20),
        DefaultTextFormField(
          title: '비밀번호 확인',
          label: '4 ~ 10자',
          onChanged: (value) {},
        ),
      ],
    );
  }
}
