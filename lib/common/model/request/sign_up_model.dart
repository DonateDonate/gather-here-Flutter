import 'package:json_annotation/json_annotation.dart';

part 'sign_up_model.g.dart';

// Post: /members Request Body
@JsonSerializable()
class SignUpModel {
  final String identity;
  final String password;

  SignUpModel({
    required this.identity,
    required this.password,
  });

  factory SignUpModel.fromJson(Map<String, dynamic> json) =>
      _$SignUpModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignUpModelToJson(this);
}
