import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/model/request/sign_up_model.dart';
import 'package:gather_here/common/repository/auth_repository.dart';

// State
class SignUpState {
  String id; // id
  String pw; // password
  String pwConfirm; // password

  bool get isButtonEnalbed {
    return id.length == 11 && pw == pwConfirm && (pw.length >= 4 && pw.length <= 10);
  }

  SignUpState({
    this.id = '',
    this.pw = '',
    this.pwConfirm = '',
  });
}

// Provider

final signUpProvider = AutoDisposeStateNotifierProvider<SignUpProvider, SignUpState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignUpProvider(authRepo: repo);
});

class SignUpProvider extends StateNotifier<SignUpState> {
  final AuthRepository authRepo;

  SignUpProvider({
    required this.authRepo,
  }) : super(SignUpState());

  void _setState() {
    state = SignUpState(id: state.id, pw: state.pw, pwConfirm: state.pwConfirm);
  }

  void idValueChanged(String value) {
    state.id = value;
    _setState();
  }

  void pwValueChanged(String value) {
    state.pw = value;
    _setState();
  }

  void pwConfirmValueChanged(String value) {
    state.pwConfirm = value;
    _setState();
  }

  Future<bool> postSignUp() async {
    try {
      await authRepo.postSignUp(body: SignUpModel(identity: state.id, password: state.pw));
      return true;
    } catch(err) {
      return false;
    }
  }
}
