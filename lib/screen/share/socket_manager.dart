import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gather_here/common/const/const.dart';
import 'package:gather_here/common/model/socket_model.dart';
import 'package:gather_here/common/storage/storage.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final socketManagerProvider = Provider((ref) {
  final storage = ref.watch(storageProvider);
  return SocketManager(storage: storage);
});

class SocketManager {
  late final WebSocketChannel _channel;
  final FlutterSecureStorage storage;

  SocketManager({
    required this.storage,
  });

  Future<void> connect() async {
    final token = await storage.read(key: StorageKey.accessToken.name);

    print('token: $token');

    final wsUrl = Uri.parse(Const.socketUrl);
    _channel = IOWebSocketChannel.connect(
      wsUrl,
      headers: {'Authorization': '$token'},
    );

    await _channel.ready;

    print('connect?');


  }

  void close() async {
    _channel.sink.close(1000);
  }

  Stream<dynamic> observeConnection() {
    return _channel.stream;
  }

  void deliveryMyInfo(SocketModel model) {
    final jsonString = jsonEncode(model.toJson());
    _channel.sink.add(jsonString);

    print('create!!');
  }
}
