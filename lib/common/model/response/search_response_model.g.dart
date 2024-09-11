// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResponseModel _$SearchResponseModelFromJson(Map<String, dynamic> json) =>
    SearchResponseModel(
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => SearchDocumentsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchResponseModelToJson(
        SearchResponseModel instance) =>
    <String, dynamic>{
      'documents': instance.documents,
    };

SearchDocumentsModel _$SearchDocumentsModelFromJson(
        Map<String, dynamic> json) =>
    SearchDocumentsModel(
      category_group_name: json['category_group_name'] as String?,
      address_name: json['address_name'] as String?,
      road_address_name: json['road_address_name'] as String?,
      place_name: json['place_name'] as String?,
      place_url: json['place_url'] as String?,
      distance: json['distance'] as String?,
      phone: json['phone'] as String?,
      x: json['x'] as String,
      y: json['y'] as String,
    );

Map<String, dynamic> _$SearchDocumentsModelToJson(
        SearchDocumentsModel instance) =>
    <String, dynamic>{
      'category_group_name': instance.category_group_name,
      'address_name': instance.address_name,
      'road_address_name': instance.road_address_name,
      'place_name': instance.place_name,
      'place_url': instance.place_url,
      'distance': instance.distance,
      'phone': instance.phone,
      'x': instance.x,
      'y': instance.y,
    };
