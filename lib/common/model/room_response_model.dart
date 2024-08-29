import 'package:json_annotation/json_annotation.dart';

part 'room_response_model.g.dart';

@JsonSerializable()
class RoomResponseModel {
  final int roomSeq;
  final double destinationLat;
  final double destinationLng;
  final String destinationName;
  final String encounterDate;
  final String shareCode;



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