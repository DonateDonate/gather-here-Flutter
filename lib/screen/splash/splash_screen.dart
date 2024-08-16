import 'package:flutter/material.dart';
import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/screen/login/login_screen.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  static get name => 'splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _goLogin();
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

  void _goLogin() async {
    await Future.delayed(
      Duration(seconds: 2),
      () {
        context.goNamed(LoginScreen.name);
      },
    );
  }
}
