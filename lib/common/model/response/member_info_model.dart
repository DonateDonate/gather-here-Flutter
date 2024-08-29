import 'package:json_annotation/json_annotation.dart';

part 'member_info_model.g.dart';

@JsonSerializable()
class MemberInfoModel {
  final String nickname;
  final String identity; // 전화번호
  final String? profileImageUrl;

  MemberInfoModel({
    required this.nickname,
    required this.identity,
    this.profileImageUrl,
  });

  MemberInfoModel copyWith({
    final String? nickname,
    final String? identity, // 전화번호
    final String? profileImageUrl,
}) {
    return MemberInfoModel(
      nickname: nickname ?? this.nickname,
      identity: identity ?? this.identity,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  factory MemberInfoModel.fromJson(Map<String, dynamic> json) =>
      _$MemberInfoModelFromJson(json);
}