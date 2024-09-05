import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/model/room_response_model.dart';
import 'package:gather_here/screen/share/share_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ShareScreen extends ConsumerStatefulWidget {
  static get name => 'share';
  final String isHost;
  final RoomResponseModel roomModel;

  const ShareScreen({
    required this.isHost,
    required this.roomModel,
    super.key,
  });

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  late final WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();

    ref.read(shareProvider.notifier)
        .setInitState(widget.isHost, widget.roomModel);
    ref.read(shareProvider.notifier).connectSocket();

  }

  @override
  void dispose() {
    super.dispose();

    _channel.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(),
    );
  }
}
