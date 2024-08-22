import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/screen/home/home_screen.dart';
import 'package:gather_here/screen/login/login_screen.dart';
import 'package:gather_here/screen/splash/splash_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static get name => 'splash';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _checkLoginState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Center(
        child: Text(
          "Splash",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  void _checkLoginState() async {
    await Future.delayed(Duration(seconds: 2));

    final result = await ref.read(splashProvier.notifier).getAppInfo();

    if (result) {
      context.goNamed(HomeScreen.name);
    } else {
      context.goNamed(LoginScreen.name);
    }
  }
}
