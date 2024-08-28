import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// kakao api를 위한 dio
final dioKakaoProvider = Provider((ref) {
  final dio = Dio();
  dio.interceptors.add(KakaoInterceptor());
  return dio;
});

class KakaoInterceptor extends Interceptor {

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    debugPrint('[REQ] [${options.method}] ${options.uri}');

    options.headers.addAll({'Authorization': 'KakaoAK 890ae0f1508c81a00e1a5b0c1c76c8cb'});

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');
    debugPrint(err.stackTrace.toString());

    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        '[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}');

    super.onResponse(response, handler);
  }
}
