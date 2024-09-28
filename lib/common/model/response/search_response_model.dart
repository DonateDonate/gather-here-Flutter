import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_response_model.g.dart';

@JsonSerializable()
class SearchResponseModel {
  final List<SearchDocumentsModel>? documents;

  SearchResponseModel({
    required this.documents,
  });
  
  factory SearchResponseModel.fromJson(Map<String, dynamic> json)
  => _$SearchResponseModelFromJson(json);
}

// Get: /keyword Response Body
@JsonSerializable()
class SearchDocumentsModel {
  final String? category_group_name; // 카테고리 이름
  final String? address_name; // 주소
  final String? road_address_name; // 도로명주소
  final String? place_name; // 장소 이름
  final String? place_url; // 장소 url
  final String? distance; // 거리
  final String? phone; // 전화번호
  final String x; // 경도
  final String y; // 위도
  BitmapDescriptor? markerIcon; // 마커 아이콘

  SearchDocumentsModel({
    required this.category_group_name,
    required this.address_name,
    required this.road_address_name,
    required this.place_name,
    required this.place_url,
    required this.distance,
    required this.phone,
    required this.x,
    required this.y,
    this.markerIcon,
  });

  factory SearchDocumentsModel.fromJson(Map<String, dynamic> json) =>
      _$SearchDocumentsModelFromJson(json);
}
