// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomResponseModel _$RoomResponseModelFromJson(Map<String, dynamic> json) =>
    RoomResponseModel(
      roomSeq: (json['roomSeq'] as num).toInt(),
      destinationLat: (json['destinationLat'] as num).toDouble(),
      destinationLng: (json['destinationLng'] as num).toDouble(),
      destinationName: json['destinationName'] as String,
      encounterDate: json['encounterDate'] as String,
      shareCode: json['shareCode'] as String,
    );

Map<String, dynamic> _$RoomResponseModelToJson(RoomResponseModel instance) =>
    <String, dynamic>{
      'roomSeq': instance.roomSeq,
      'destinationLat': instance.destinationLat,
      'destinationLng': instance.destinationLng,
      'destinationName': instance.destinationName,
      'encounterDate': instance.encounterDate,
      'shareCode': instance.shareCode,
    };
