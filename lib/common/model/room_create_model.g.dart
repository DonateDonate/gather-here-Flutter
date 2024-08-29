// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_create_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomCreateModel _$RoomCreateModelFromJson(Map<String, dynamic> json) =>
    RoomCreateModel(
      destinationLat: (json['destinationLat'] as num).toDouble(),
      destinationLng: (json['destinationLng'] as num).toDouble(),
      destinationName: json['destinationName'] as String,
      encounterDate: json['encounterDate'] as String,
    );

Map<String, dynamic> _$RoomCreateModelToJson(RoomCreateModel instance) =>
    <String, dynamic>{
      'destinationLat': instance.destinationLat,
      'destinationLng': instance.destinationLng,
      'destinationName': instance.destinationName,
      'encounterDate': instance.encounterDate,
    };
