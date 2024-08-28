import 'package:flutter/material.dart';
import 'package:gather_here/common/components/default_button.dart';
import 'package:gather_here/common/const/colors.dart';

class DefaultAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? image;
  final Function() onTabConfirm;

  const DefaultAlertDialog({
    required this.title,
    required this.content,
    required this.onTabConfirm,
    this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontWeight: FontWeight.w500
        ),
      ),
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: AppColor.grey1
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: DefaultButton(
                title: '취소',
                onTap: () {
                  Navigator.of(context).pop();
                },
                backgroundColor: AppColor.grey2,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: DefaultButton(
                title: '확인',
                onTap: () {
                  onTabConfirm();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ],
      backgroundColor: AppColor.background,
      surfaceTintColor: AppColor.grey2,
    );
  }
}