import 'package:gather_here/screen/design_system/design_system_button_screen.dart';
import 'package:gather_here/screen/design_system/design_system_screen.dart';
import 'package:gather_here/screen/design_system/design_system_text_form_field_screen.dart';

import 'package:gather_here/screen/home/home_screen.dart';
import 'package:gather_here/auth/view/login_screen/login_screen.dart';
import 'package:gather_here/screen/splash/splash_screen.dart';

import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: SplashScreen.name,
      builder: (context, state) => SplashScreen(),
    ),

    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, state) => LoginScreen(),
    ),

    GoRoute(
      path: '/home',
      name: HomeScreen.name,
      builder: (context, state) => HomeScreen(),
    ),
  ],
);

final dsRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => DesignSystemScreen(),
      routes: [
        GoRoute(path: 'button', name: 'Button', builder: (_, state) => DesignSystemButtonScreen()),
        GoRoute(path: 'textField', name: 'TextField', builder: (_, state) => DesignSystemTextFormFieldScreen())
      ]
    ),
  ],
);
