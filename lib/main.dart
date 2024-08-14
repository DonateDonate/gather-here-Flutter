import 'package:flutter/material.dart';
import 'package:gather_here/common/router/router.dart';

void main() {
  // runApp(_App());
  runApp(_DesignSystemApp());
}

class _App extends StatelessWidget {
  const _App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(fontFamily: 'Pretendard'),
      routerConfig: router,
    );
  }
}

class _DesignSystemApp extends StatelessWidget {
  const _DesignSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(fontFamily: 'Pretendard'),
      routerConfig: dsRouter,
    );
  }
}
