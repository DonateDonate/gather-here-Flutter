import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gather_here/common/router/router.dart';
import 'package:gather_here/common/storage/storage.dart';
import 'package:gather_here/screen/login/login_screen.dart';
import 'package:go_router/go_router.dart';

final dioProvider = Provider((ref) {
  final dio = Dio();
  final interceptor = ref.watch(interceptorProvider);
  dio.interceptors.add(interceptor);
  return dio;
});

final interceptorProvider = Provider((ref) {
  final storage = ref.watch(storageProvider);
  final router = ref.watch(routerProvider);
  return CustomInterceptor(storage: storage, router: router);
});

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final GoRouter router;

  CustomInterceptor({
    required this.storage,
    required this.router,
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
    debugPrint('[ERR Res] ${err.response?.data}');

    // 토큰 갱신 오류가 아니면, 그대로 에러 던지기
    if (err.response?.statusCode != 401) {
      return handler.reject(err);
    }

    final data = err.response?.data as Map<String, dynamic>;
    final statusCode = data['code'];

    print('ErrorCode: $statusCode');

    // accessToken 만료일때 처리 (9102: invalid, 9103: exipre)
    if (statusCode == 9102 || statusCode == 9103) {
      return _retry(err, handler);
    }

    // refrehToken 만료 && accessToken 없을때 처리 (로그인 화면으로 보내기)
    if (statusCode == 9104 || statusCode == 9105 || statusCode == 9106) {
      _goLogin();
    }

    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}');

    // Headers에 토큰이 있다면 토큰 정보를 스토리지에 저장
    final refreshToken = response.headers.value('refresh-token');
    if (refreshToken != null) {
      storage.write(key: StorageKey.refreshToken.name, value: refreshToken);
      print('refreshToken 저장');
    }

    final accessToken = response.headers.value('authorization');
    if (accessToken != null) {
      storage.write(key: StorageKey.accessToken.name, value: accessToken);
      print('accessToken 저장');
    }

    super.onResponse(response, handler);
  }

  // accessToken 갱신
  void _retry(DioException err, ErrorInterceptorHandler handler) async {
    final refreshToken = await storage.read(key: StorageKey.refreshToken.name);
    final options = err.requestOptions;

    options.headers.addAll({'Refresh-token': refreshToken});

    try {
      final newResponse = await Dio().fetch(options);
      final newRefreshToken = newResponse.headers.value('refresh-token');

      if (newRefreshToken != null) {
        storage.write(key: StorageKey.refreshToken.name, value: newRefreshToken);
        print('refreshToken 저장');
      }

      final newAccessToken = newResponse.headers.value('authorization');
      if (newAccessToken != null) {
        storage.write(key: StorageKey.accessToken.name, value: newAccessToken);
        print('accessToken 저장');
      }

      return handler.resolve(newResponse);
    } catch (error) {
      // accessToken 갱신 실패했을때 (refreshToken이 만료됬을땜) 로그인 페이지로 이동
      _goLogin();
    }
  }

  void _goLogin() {
    storage.delete(key: StorageKey.refreshToken.name);
    storage.delete(key: StorageKey.accessToken.name);
    router.goNamed(LoginScreen.name);
  }
}
