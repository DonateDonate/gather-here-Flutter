import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storageProvider = Provider((ref) => FlutterSecureStorage());

// 스토리지 key값 정의
enum StorageKey {
  accessToken,
  refreshToken,
}
