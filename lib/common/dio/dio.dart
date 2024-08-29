import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gather_here/common/storage/storage.dart';

final dioProvider = Provider((ref) {
  final dio = Dio();

  final storage = ref.watch(storageProvider);

  dio.interceptors.add(
    CustomInterceptor(storage: storage),
  );

  return dio;
});

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  CustomInterceptor({
    required this.storage,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    debugPrint('[REQ] [${options.method}] ${options.uri}');

    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');

      final token = await storage.read(key: StorageKey.accessToken.name);
      options.headers.addAll({'Authorization': token});
      debugPrint('[REQ] accessToken 저장');
    }

    if (options.headers['refreshToken'] == 'false') {
      options.headers.remove('refreshToken');

      final token = await storage.read(key: StorageKey.refreshToken.name);
      options.headers.addAll({'Refresh-token': token});
      debugPrint('[REQ] refreshToken 저장');
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');
    debugPrint(err.stackTrace.toString());

    // 토큰 갱신 오류가 아니면, 그대로 에러 던지기
    if (err.response?.statusCode != 401) {
      return handler.reject(err);
    }

    final data = err.response?.data as Map<String, dynamic>;
    final statusCode = data['code'];

    print('ErrorCode: $statusCode');

    // accessToken 만료일때 처리 (9102: invalid, 9103: exipre)
    if (statusCode == 9102 || statusCode == 9103) {
      final refreshToken = await storage.read(key: StorageKey.refreshToken.name);
      // TODO: - AccessToken 갱신로직 (동작 확인해야함)

      final options = err.requestOptions;
      options.headers.addAll({'Refresh-token': refreshToken});

      return handler.resolve(err.response!);
    }

    // refrehToken 만료 && accessToken 없을때 처리 (로그인 화면으로 보내기)
    if (statusCode == 9104 || statusCode == 9105 || statusCode == 9106) {
      // TODO: 토큰 삭제 처리 후 로그인 화면으로 보내기
      storage.delete(key: StorageKey.refreshToken.name);
      storage.delete(key: StorageKey.accessToken.name);
    }

    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        '[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}');

    // Headers에 토큰이 있다면 토큰 정보를 스토리지에 저장
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
