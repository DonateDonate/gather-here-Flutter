import 'package:json_annotation/json_annotation.dart';

part 'member_info_model.g.dart';

@JsonSerializable()
class MemberInfoModel {
  String nickname;
  String identity; // 전화번호
  String? profileImageUrl;

  MemberInfoModel({
    required this.nickname,
    required this.identity,
    this.profileImageUrl,
  });

  factory MemberInfoModel.fromJson(Map<String, dynamic> json) =>
      _$MemberInfoModelFromJson(json);
}