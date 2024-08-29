import 'package:json_annotation/json_annotation.dart';

part 'room_response_model.g.dart';

@JsonSerializable()
class RoomResponseModel {
  final int roomSeq; // 방 번호
  final double destinationLat; // 목적지 위도
  final double destinationLng; // 목적지 경도
  final String destinationName; // 목저지 이름
  final String encounterDate; // 만남 날짜
  final String shareCode; // 공유코드 4자리

  RoomResponseModel({
    required this.roomSeq,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
    required this.encounterDate,
    required this.shareCode,
  });

  factory RoomResponseModel.fromJson(Map<String, dynamic> json)
  => _$RoomResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomResponseModelToJson(this);
}