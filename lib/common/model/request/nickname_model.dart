import 'package:json_annotation/json_annotation.dart';

part 'nickname_model.g.dart';

@JsonSerializable()
class NicknameModel {
  final String nickname;

  NicknameModel({
    required this.nickname,
  });

  factory NicknameModel.fromJson(Map<String, dynamic> json) =>
      _$NicknameModelFromJson(json);

  Map<String, dynamic> toJson() => _$NicknameModelToJson(this);
}