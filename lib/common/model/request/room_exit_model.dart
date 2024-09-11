import 'package:json_annotation/json_annotation.dart';

part 'room_exit_model.g.dart';

// Post: /rooms/exit Request Body
@JsonSerializable()
class RoomExitModel {
  final int roomSeq;

  RoomExitModel({
    required this.roomSeq,
  });

  factory RoomExitModel.fromJson(Map<String, dynamic> json) =>
      _$RoomExitModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomExitModelToJson(this);
}