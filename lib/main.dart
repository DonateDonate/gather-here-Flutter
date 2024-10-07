import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/provider/provider_observer.dart';
import 'package:gather_here/common/router/router.dart';
import 'package:permission_handler/permission_handler.dart';

import 'common/background/initialize_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  await initializeService();
  runApp(
    ProviderScope(observers: [Logger()], child: _App()),
  );
}

Future<void> requestPermissions() async {
  await Permission.notification.request();
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
