import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/provider/provider_observer.dart';
import 'package:gather_here/common/router/router.dart';
import 'package:gather_here/common/utils/utils.dart';

import 'common/background/initialize_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Utils.requestNotificationPermission();
  }

  await initializeService();
  runApp(
    ProviderScope(observers: [Logger()], child: _App()),
  );
}

class _App extends ConsumerWidget {
  const _App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('ko', ''), // Korean, no country code
      ],
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
