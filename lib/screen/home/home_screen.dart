import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '홈스크린',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 40,
          ),
        ),
      ),
    );
  }
}
