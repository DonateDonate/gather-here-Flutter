import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/screen/home/home_screen.dart';
import 'package:gather_here/screen/login/login_screen.dart';
import 'package:gather_here/screen/splash/splash_provider.dart';
import 'package:go_router/go_router.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'asset/img/appIcon.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 30),

            Text('여기로모여라', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),),
          ],
        ),
      ),
    );
  }

  void _checkLoginState() async {
    await Future.delayed(Duration(seconds: 2));

    final getAppInfoResult = await ref.read(splashProvier.notifier).getAppInfo();

    if (getAppInfoResult) {
      context.goNamed(HomeScreen.name);
    } else {
      context.goNamed(LoginScreen.name);
    }
  }
}
