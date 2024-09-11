import 'package:json_annotation/json_annotation.dart';

part 'socket_response_model.g.dart';

@JsonSerializable()
class SocketResponseModel {
  final int roomSeq;
  final List<SocketMemberListModel> memberLocationResList;
  final SocketScoreModel scoreRes;

  SocketResponseModel({
    required this.roomSeq,
    required this.memberLocationResList,
    required this.scoreRes,
  });

  factory SocketResponseModel.fromJson(Map<String, dynamic> json)
  => _$SocketResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SocketResponseModelToJson(this);
}

@JsonSerializable()
class SocketMemberListModel {
  final int memberSeq;
  final String nickname;
  final String? imageUrl;
  final double presentLat;
  final double presentLng;
  final double destinationDistance;

  SocketMemberListModel({
    required this.memberSeq,
    required this.nickname,
    this.imageUrl,
    required this.presentLat,
    required this.presentLng,
    required this.destinationDistance,
  });

  factory SocketMemberListModel.fromJson(Map<String, dynamic> json)
  => _$SocketMemberListModelFromJson(json);

  Map<String, dynamic> toJson() => _$SocketMemberListModelToJson(this);
}

@JsonSerializable()
class SocketScoreModel {
  final int? goldMemberSeq;
  final int? silverMemberSeq;
  final int? bronzeMemberSeq;

  SocketScoreModel({
    this.goldMemberSeq,
    this.silverMemberSeq,
    this.bronzeMemberSeq,
  });

  factory SocketScoreModel.fromJson(Map<String, dynamic> json)
  => _$SocketScoreModelFromJson(json);

  Map<String, dynamic> toJson() => _$SocketScoreModelToJson(this);
}
