import 'package:flutter/material.dart';
import 'package:gather_here/common/const/colors.dart';

// GH 기본 TextField
class DefaultTextFormField extends StatefulWidget {
  final double height;
  final double width;
  final String title;
  final String label; // textField에 들어갈 안내 텍스트
  final Color filledColor; // textField 배경 색
  final double radius; // textField 곡률
  final TextEditingController controller; // 입력된 텍스트를 제어 및 관리
  final String? Function(String?)? formFieldValidator; // 텍스트 입력 검증
  final TextInputType typeDef; // 키보드 입력 타입
  final bool obscureText; // 입력된 텍스트 가리기, 비밀번호 입력 시 true
  final void Function(String)? onChanged; // 입력된 텍스트가 수정될  호출되는 콜백

  const DefaultTextFormField({
    required this.label,
    required this.controller,
    this.height = 60,
    this.width = double.infinity,
    this.title = '',
    this.filledColor = AppColor.grey4,
    this.radius = 12,
    this.formFieldValidator,
    this.typeDef = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    super.key,
  });

  @override
  State<DefaultTextFormField> createState() => _DefaultTextFormFieldState();
}

class _DefaultTextFormFieldState extends State<DefaultTextFormField> {
  @override
  Widget build(BuildContext context) {
    double calculatedHeight = widget.height;
    if (widget.title.isNotEmpty) {
      calculatedHeight = 100;
    }
    return SizedBox(
      width: widget.width,
      height: calculatedHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.title.isNotEmpty)
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16.0,
                color: AppColor.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (widget.title.isNotEmpty)
            const SizedBox(
              height: 14.0,
            ),
          TextFormField(
            controller: widget.controller,
            validator: widget.formFieldValidator,
            cursorColor: AppColor.black,
            keyboardType: widget.typeDef,
            obscureText: widget.obscureText,
            onChanged: widget.onChanged,
            style: const TextStyle(fontSize: 16, color: AppColor.black),
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: const TextStyle(fontSize: 16, color: Colors.black),
              filled: true,
              fillColor: widget.filledColor,
              border: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: AppColor.grey2,
                  ),
                  borderRadius: BorderRadius.circular(widget.radius)),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: AppColor.grey2,
                  ),
                  borderRadius: BorderRadius.circular(widget.radius)),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: AppColor.black,
                  ),
                  borderRadius: BorderRadius.circular(widget.radius)),
            ),
          ),
        ],
      ),
    );
  }
}
