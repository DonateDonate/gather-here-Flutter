import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gather_here/common/components/default_button.dart';
import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/common/components/default_text_form_field.dart';
import 'package:gather_here/common/const/colors.dart';
import 'package:gather_here/common/model/request/sign_up_model.dart';
import 'package:gather_here/common/utils/utils.dart';
import 'package:gather_here/screen/sign_up/sign_up_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SignUpScreen extends HookConsumerWidget {
  static String get name => 'SignUp';

  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = useState('');
    final pw = useState('');
    final pwConfirm = useState('');
    final isTermsChecked = useState(false);

    bool isButtonEnabled() {
      return id.value.length == 11 &&
          pw.value == pwConfirm.value &&
          (pw.value.length >= 4 && pw.value.length <= 10) &&
          isTermsChecked.value == true;
    }

    // final vm = ref.watch(signUpProvider);

    return DefaultLayout(
      title: '회원가입',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TextFields(
                      onIdChanged: (value) => id.value = value,
                      onPwChanged: (value) => pw.value = value,
                      onPwConfirmChanged: (value) => pwConfirm.value = value,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    _CheckBox(termsState: isTermsChecked.value, isChecked: (value) {
                      isTermsChecked.value = value!;
                    }),

                    const Spacer(),
                    DefaultButton(
                      title: '회원가입',
                      isEnabled: isButtonEnabled(),
                      onTap: () async {
                        final result =
                            await ref.read(signUpProvider(SignUpModel(
                          identity: id.value,
                          password: pw.value,
                        )).future);

                        final message = result ? '회원가입 성공' : '회원가입 실패';

                        Utils.showSnackBar(context, message);

                        if (result) {
                          context.pop();
                        }
                      },
                    ),
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

class _TextFields extends StatelessWidget {
  final ValueChanged<String> onIdChanged;
  final ValueChanged<String> onPwChanged;
  final ValueChanged<String> onPwConfirmChanged;

  const _TextFields({
    required this.onIdChanged,
    required this.onPwChanged,
    required this.onPwConfirmChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultTextFormField(
          title: '아이디',
          label: '휴대폰 번호',
          keyboardType: const TextInputType.numberWithOptions(),
          onChanged: onIdChanged,
        ),
        const SizedBox(height: 20),
        DefaultTextFormField(
          title: '비밀번호',
          label: '4 ~ 10자',
          obscureText: true,
          onChanged: onPwChanged,
        ),
        const SizedBox(height: 20),
        DefaultTextFormField(
          title: '비밀번호 확인',
          label: '4 ~ 10자',
          obscureText: true,
          onChanged: onPwConfirmChanged,
        ),
      ],
    );
  }
}

class _CheckBox extends StatelessWidget {
  final bool termsState;
  final ValueChanged<bool?> isChecked;

  const _CheckBox({
    required this.termsState,
    required this.isChecked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: GestureDetector(
        onTap: () {
          launchUrlString('https://placid-sneeze-769.notion.site/11f29e9854d48036a272c3cbb59d9e62');
        },
        child: const Text(
          '이용 약관에 동의해 주세요(필수)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      value: termsState,
      onChanged: (bool? value) {
        isChecked(value);
      },
      activeColor: AppColor.main,
    );
  }
}
