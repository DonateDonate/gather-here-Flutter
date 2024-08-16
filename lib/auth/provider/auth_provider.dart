import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/auth/model/login_model.dart';
import 'package:gather_here/auth/repository/auth_repository.dart';

final authProvider = StateNotifierProvider<AuthProvider, bool>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthProvider(repository: repo);
});

class AuthProvider extends StateNotifier<bool> {
  final AuthRepository repository;

  AuthProvider({
    required this.repository,
  }) : super(false);

  Future<bool> postLogin({
    required String id,
    required String pw,
  }) async {
    try {
      await repository.postLogin(body: LoginModel(identity: id, password: pw));
      state = true;
    } catch(error) {
      state = false;
    }

    return state;
  }
}
