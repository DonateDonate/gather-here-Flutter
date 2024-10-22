import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/model/request/sign_up_model.dart';
import 'package:gather_here/common/repository/auth_repository.dart';

final signUpProvider =
    FutureProvider.family<bool, SignUpModel>((ref, signUpModel) async {
  final repo = ref.watch(authRepositoryProvider);
  try {
    await repo.postSignUp(
        body: SignUpModel(
      identity: signUpModel.identity,
      password: signUpModel.password,
    ));
    return true;
  } catch (err) {
    debugPrint('postSignUp Err: $err');
    return false;
  }
});
