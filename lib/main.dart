import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/provider/provider_observer.dart';
import 'package:gather_here/common/router/router.dart';

void main() {
  runApp(
    ProviderScope(observers: [Logger()], child: _App()),
  );

  // runApp(_DesignSystemApp());
}

class _App extends ConsumerWidget {
  const _App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      theme: ThemeData(fontFamily: 'Pretendard'),
      routerConfig: ref.read(routerProvider),
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
