import 'package:gather_here/common/model/response/room_response_model.dart';
import 'package:gather_here/screen/debug/debug_screen.dart';
import 'package:gather_here/screen/my_page/my_page_screen.dart';
import 'package:gather_here/screen/share/share_screen.dart';
import 'package:gather_here/screen/sign_up/sign_up_screen.dart';
import 'package:gather_here/screen/design_system/design_system_button_screen.dart';
import 'package:gather_here/screen/design_system/design_system_screen.dart';
import 'package:gather_here/screen/design_system/design_system_text_form_field_screen.dart';

import 'package:gather_here/screen/home/home_screen.dart';
import 'package:gather_here/screen/login/login_screen.dart';
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
      routes: [
        GoRoute(
          path: 'signup',
          name: SignUpScreen.name,
          builder: (context, state) => SignUpScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/debug',
      name: DebugScreen.name,
      builder: (context, state) => DebugScreen(),
    ),
    GoRoute(path: '/home', name: HomeScreen.name, builder: (context, state) => HomeScreen(), routes: [
      GoRoute(
        path: 'share/:isHost',
        name: ShareScreen.name,
        builder: (context, state) {
          final isHost = state.pathParameters['isHost'] ?? 'true';
          final roomModel = state.extra as RoomResponseModel;
          return ShareScreen(
            isHost: isHost,
            roomModel: roomModel,
          );
        },
      ),
    ]),
    GoRoute(
      path: '/my_page',
      name: MyPageScreen.name,
      builder: (context, state) => MyPageScreen(),
    ),
  ],
);

final dsRouter = GoRouter(
  routes: [
    GoRoute(path: '/', name: 'home', builder: (context, state) => DesignSystemScreen(), routes: [
      GoRoute(path: 'button', name: 'Button', builder: (_, state) => DesignSystemButtonScreen()),
      GoRoute(path: 'textField', name: 'TextField', builder: (_, state) => DesignSystemTextFormFieldScreen())
    ]),
  ],
);
