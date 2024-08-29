import 'package:json_annotation/json_annotation.dart';

part 'password_model.g.dart';

@JsonSerializable()
class PasswordModel {
  final String password;

  PasswordModel({
    required this.password,
  });

  factory PasswordModel.fromJson(Map<String, dynamic> json) =>
      _$PasswordModelFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordModelToJson(this);
}