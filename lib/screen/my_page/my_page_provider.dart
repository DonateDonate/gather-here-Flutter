import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gather_here/common/model/request/nickname_model.dart';
import 'package:gather_here/common/model/request/password_model.dart';
import 'package:gather_here/common/repository/member_repository.dart';
import 'package:gather_here/common/storage/storage.dart';

import '../../common/repository/auth_repository.dart';

class MyPageState {
  int? changeNickName;
  int? changePassWord;
  int? deleteMember;

  MyPageState({
    this.changeNickName,
    this.changePassWord,
    this.deleteMember,
  });
}

final myPageProvider =
    AutoDisposeStateNotifierProvider<MyPageProvider, MyPageState>((ref) {
  final memberRepository = ref.watch(memberRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  final storage = ref.watch(storageProvider);

  return MyPageProvider(
    memberRepository: memberRepository,
    authRepository: authRepository,
    storage: storage,
  );
});

class MyPageProvider extends StateNotifier<MyPageState> {
  final MemberRepository memberRepository;
  final AuthRepository authRepository;
  final FlutterSecureStorage storage;

  MyPageProvider({
    required this.memberRepository,
    required this.authRepository,
    required this.storage,
  }) : super(MyPageState()) {
    // 초기 상태를 로딩 상태로 설정
  }

  void _setState() {
    state = MyPageState(
      changeNickName: state.changeNickName,
      changePassWord: state.changePassWord,
      deleteMember: state.deleteMember,
    );
  }

  Future<void> changeNickName(String nickName) async {
    try {
      await memberRepository.patchChangeNickName(
        body: NicknameModel(nickname: nickName),
      );
      state.changeNickName = 0;
      _setState();
    } catch (e) {
      debugPrint('changeNickName Err: $e');
      state.changeNickName = 1;
      _setState();
    }
  }

  Future<void> changePassWord(String passWord) async {
    try {
      await memberRepository.patchChangePassWord(
        body: PasswordModel(password: passWord),
      );
      state.changePassWord = 0;
      _setState();
    } catch (e) {
      debugPrint('changePassWord Err: $e');
      state.changePassWord = 1;
      _setState();
    }
  }

  Future<void> deleteMember() async {
    try {
      await authRepository.deleteMember();
      await storage.deleteAll();
      state.deleteMember = 0;
      _setState();
    } catch (e) {
      debugPrint('deleteMember Err: $e');
      state.deleteMember = 1;
      _setState();
    }
  }
}
