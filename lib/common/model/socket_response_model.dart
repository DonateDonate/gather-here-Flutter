import 'package:json_annotation/json_annotation.dart';

part 'socket_response_model.g.dart';

@JsonSerializable()
class SocketResponseModel {
  final int roomSeq;
  final List<SocketMemberListModel> memberLocationResList;

  SocketResponseModel({
    required this.roomSeq,
    required this.memberLocationResList,
  });

  factory SocketResponseModel.fromJson(Map<String, dynamic> json)
  => _$SocketResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SocketResponseModelToJson(this);
}

@JsonSerializable()
class SocketMemberListModel {
  final int memberSeq;
  final String nickname;
  final String imageUrl;
  final double presentLat;
  final double presentLng;
  final double destinationDistance;
  int? rank;

  SocketMemberListModel({
    required this.memberSeq,
    required this.nickname,
    required this.imageUrl,
    required this.presentLat,
    required this.presentLng,
    required this.destinationDistance,
    this.rank,
  });

  factory SocketMemberListModel.fromJson(Map<String, dynamic> json)
  => _$SocketMemberListModelFromJson(json);

  Map<String, dynamic> toJson() => _$SocketMemberListModelToJson(this);
}