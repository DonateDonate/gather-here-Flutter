import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 공통 UI 컴포넌트를 개발할때마다 추가해주세요
class DesignSystemScreen extends StatelessWidget {
  final list = [
    'Button',
    'Dialog',
    'BottomSheet',
    'TextField'
  ];

  DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Design System')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.separated(
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  context.pushNamed(list[index]);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Text(
                        list[index],
                        style: TextStyle(fontSize: 18),
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
            itemCount: list.length,
          ),
        ),
      ),
    );
  }
}
