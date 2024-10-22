import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gather_here/common/repository/member_repository.dart';
import 'package:gather_here/common/router/router.dart';
import 'package:gather_here/common/storage/storage.dart';
import 'package:gather_here/screen/login/login_screen.dart';
import 'package:go_router/go_router.dart';

import '../../common/repository/auth_repository.dart';

class MyPageState {
  String? message;

  MyPageState({
    this.message,
  });
}

final myPageProvider = AutoDisposeStateNotifierProvider<MyPageProvider, MyPageState>((ref) {
  final memberRepository = ref.watch(memberRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  final router = ref.watch(routerProvider);
  final storage = ref.watch(storageProvider);

  return MyPageProvider(
    memberRepository: memberRepository,
    authRepository: authRepository,
    storage: storage,
    router: router
  );
});

class MyPageProvider extends StateNotifier<MyPageState> {
  final MemberRepository memberRepository;
  final AuthRepository authRepository;
  final FlutterSecureStorage storage;
  final GoRouter router;

  MyPageProvider({
    required this.memberRepository,
    required this.authRepository,
    required this.storage,
    required this.router,
  }) : super(MyPageState());

  void _setState() async {
    state = MyPageState(message: state.message);
    await Future.delayed(const Duration(seconds: 1));
    state = MyPageState(message: null);
  }

  Future<void> deleteMember() async {
    try {
      await authRepository.deleteMember();
      await storage.deleteAll();
      router.goNamed(LoginScreen.name);
    } catch (e) {
      state.message = '회원탈퇴에 실패했어요';
      _setState();
    }
  }

  Future<void> logout() async {
    try {
      await storage.deleteAll();
      router.goNamed(LoginScreen.name);
    } catch (e) {
      state.message = '로그아웃에 실패했어요';
      _setState();
    }
  }
}
