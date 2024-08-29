import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../const/colors.dart';
import 'default_button.dart';

class DefaultTextFieldDialog extends StatefulWidget {
  final String title;
  final List<String> labels;
  final Function(List<String>) onChanged;

  const DefaultTextFieldDialog({
    required this.title,
    required this.labels,
    required this.onChanged,
    super.key,
  });

  @override
  _DefaultTextFieldDialogState createState() => _DefaultTextFieldDialogState();
}

class _DefaultTextFieldDialogState extends State<DefaultTextFieldDialog> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.labels.length,
          (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: AppColor.background,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 30),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: widget.labels.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      return _TextFieldWidget(
                        label: widget.labels[index],
                        controller: _controllers[index],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                DefaultButton(
                  title: '확인',
                  onTap: () {
                    List<String> values = _controllers.map((c) => c.text).toList();
                    widget.onChanged(values);
                    context.pop();
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TextFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _TextFieldWidget({
    required this.label,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(fontSize: 16, color: AppColor.black1),
      controller: controller,
      cursorColor: AppColor.black1,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: AppColor.grey4,
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColor.grey2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColor.grey2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColor.black1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}