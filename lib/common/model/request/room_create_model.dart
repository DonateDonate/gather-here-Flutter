import 'package:json_annotation/json_annotation.dart';

part 'room_create_model.g.dart';

// POST: /room Request Body
@JsonSerializable()
class RoomCreateModel {
  final double destinationLat; // 위도
  final double destinationLng; // 경도
  final String destinationName; // 목적지 이름
  final String encounterDate; // "2029-01-07 15:33" 형식

  RoomCreateModel({
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
    required this.encounterDate,
});

  factory RoomCreateModel.fromJson(Map<String, dynamic> json)
  => _$RoomCreateModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomCreateModelToJson(this);
}

