import 'package:json_annotation/json_annotation.dart';

part 'room_join_model.g.dart';

@JsonSerializable()
class RoomJoinModel {
  final String shareCode; // 공유코드 4자리
  
  RoomJoinModel({
    required this.shareCode,
});
  
  factory RoomJoinModel.fromJson(Map<String, dynamic> json)
  => _$RoomJoinModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomJoinModelToJson(this);
}