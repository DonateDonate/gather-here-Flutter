import 'package:gather_here/screen/design_system/design_system_button_screen.dart';
import 'package:gather_here/screen/design_system/design_system_screen.dart';
import 'package:gather_here/screen/home/home_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
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
        GoRoute(path: 'button', name: 'Button', builder: (_, state) => DesignSystemButtonScreen())
      ]
    ),
  ],
);
