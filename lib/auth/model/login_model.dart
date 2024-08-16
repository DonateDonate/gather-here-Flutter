import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

// Post: /login Request Body
@JsonSerializable()
class LoginModel {
  final String identity;
  final String password;

  LoginModel({
    required this.identity,
    required this.password,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}