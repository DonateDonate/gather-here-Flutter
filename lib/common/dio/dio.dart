import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gather_here/common/storage/storage.dart';

final dioProvider = Provider((ref) {
  final dio = Dio();
  final storage = ref.watch(storageProvider);
  dio.interceptors.add(CustomInterceptor(storage: storage));
  return dio;
});

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  CustomInterceptor({
    required this.storage,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[REQ] [${options.method}] ${options.uri}');
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');

    debugPrint(err.stackTrace.toString());

    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        '[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}');

    // Headers에 토큰이 있다면 토큰정보 스토리지에 저장
    final refreshToken = response.headers.value('refresh-token');
    if (refreshToken != null) {
      storage.write(key: StorageKey.refreshToken.name, value: refreshToken);
    }

    final accessToken = response.headers.value('authorization');
    if (accessToken != null) {
      storage.write(key: StorageKey.accessToken.name, value: accessToken);
    }

    super.onResponse(response, handler);
  }
}
