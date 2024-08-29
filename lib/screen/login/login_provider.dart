import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gather_here/common/model/request/login_model.dart';
import 'package:gather_here/common/repository/auth_repository.dart';

// State
class LoginState {
  String id; // id값
  String pw; // password 값

  bool get isButtonEnabled { // button의 enabled 상태
    return id.length == 11 && pw.length >= 4 && pw.length <= 10;
  }

  LoginState({
    this.id = '',
    this.pw = '',
  });
}

// Provider

final loginProvider = AutoDisposeStateNotifierProvider<LoginProvider, LoginState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginProvider(authRepo: repo);
});

class LoginProvider extends StateNotifier<LoginState> {
  final AuthRepository authRepo;

  LoginProvider({
    required this.authRepo,
  }) : super(LoginState());

  void _setState() {
    state = LoginState(id: state.id, pw: state.pw);
  }

  void idValueChanged({required String value}) {
    state.id = value;
    _setState();
  }

  void pwValueChanged({required String value}) {
    state.pw = value;
    _setState();
  }

  Future<bool> postLogin() async {
    try {
      await authRepo.postLogin(body: LoginModel(identity: state.id, password: state.pw));
      return true;
    } catch(err) {
      return false;
    }
  }
}
