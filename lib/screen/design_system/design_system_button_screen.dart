import 'package:flutter/material.dart';
import 'package:gather_here/common/components/default_button.dart';
import 'package:gather_here/common/const/colors.dart';

class DesignSystemButtonScreen extends StatelessWidget {
  const DesignSystemButtonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buttons')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DefaultButton(title: 'Enabled', onTap: () {}),
              const SizedBox(height: 16),
              DefaultButton(title: 'Disabled', isEnabled: false, onTap: () {}),
              const SizedBox(height: 16),
              DefaultButton(title: 'Short_E', backgroundColor: AppColor.grey2, width: 140, onTap: () {}),
              const SizedBox(height: 16),
              DefaultButton(title: 'Short_D', isEnabled: false, disabledBackgroundColor: AppColor.grey3, width: 140, onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
