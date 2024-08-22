import 'package:json_annotation/json_annotation.dart';

part 'app_info_model.g.dart';

@JsonSerializable()
class AppInfoModel {
  final String appVersion; // 앱 버전정보

  AppInfoModel({
    required this.appVersion
  });
  
  factory AppInfoModel.fromJson(Map<String, dynamic> json)
  => _$AppInfoModelFromJson(json);
}