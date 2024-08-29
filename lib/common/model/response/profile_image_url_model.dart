import 'package:json_annotation/json_annotation.dart';

part 'profile_image_url_model.g.dart';

@JsonSerializable()
class ProfileImageUrlModel {
  final String imageUrl;

  ProfileImageUrlModel({
    required this.imageUrl,
  });

  factory ProfileImageUrlModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileImageUrlModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileImageUrlModelToJson(this);
}