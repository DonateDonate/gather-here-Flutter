import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/components/default_button.dart';
import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/common/components/default_text_form_field.dart';
import 'package:gather_here/screen/sign_up/sign_up_provider.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends ConsumerWidget {
  static String get name => 'SignUp';

  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(signUpProvider);

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
                    DefaultButton(
                      title: '회원가입',
                      isEnabled: vm.isButtonEnalbed,
                      onTap: () async {
                        final result = await ref
                            .read(signUpProvider.notifier)
                            .postSignUp();

                        final message = result ? '회원가입 성공' : '회원가입 실패';

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            duration: Duration(seconds: 3),
                          ),
                        );

                        if (result) {
                          context.pop();
                        }
                      },
                    ),
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

class _TextFields extends ConsumerWidget {
  const _TextFields({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Column(
      children: [
        DefaultTextFormField(
          title: '아이디',
          label: '휴대폰 번호',
          keyboardType: const TextInputType.numberWithOptions(),
          onChanged: (value) {
            ref.read(signUpProvider.notifier).idValueChanged(value);
          },
        ),
        const SizedBox(height: 20),
        DefaultTextFormField(
          title: '비밀번호',
          label: '4 ~ 10자',
          onChanged: (value) {
            ref.read(signUpProvider.notifier).pwValueChanged(value);
          },
        ),
        SizedBox(height: 20),
        DefaultTextFormField(
          title: '비밀번호 확인',
          label: '4 ~ 10자',
          onChanged: (value) {
            ref.read(signUpProvider.notifier).pwConfirmValueChanged(value);
          },
        ),
      ],
    );
  }
}
