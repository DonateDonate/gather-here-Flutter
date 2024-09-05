import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/location/location_manager.dart';
import 'package:gather_here/common/model/room_response_model.dart';
import 'package:gather_here/screen/share/share_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

    ref
        .read(shareProvider.notifier)
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

class _Map extends ConsumerStatefulWidget {
  const _Map({super.key});

  @override
  ConsumerState<_Map> createState() => _MapState();
}

class _MapState extends ConsumerState<_Map> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(37.5642135, -127.0016985),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();

    LocationManager.observePosition().listen((position) {
      print(position.toString());
      if (position != null) {
        ref.read(shareProvider.notifier).setPosition(
              position.latitude,
              position.longitude,
            );
        ref.read(shareProvider.notifier).deliveryMyInfo(2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shareProvider);
    return GoogleMap(
      initialCameraPosition: _defaultPosition,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      onMapCreated: (controller) {
        _controller.complete(controller);
      },
      markers: {
        Marker(
          markerId: MarkerId('김종민'),
          position: LatLng(
            state.myLat ?? 37.5642135,
            state.myLong ?? -127.0016985,
          ),
        )
      },
    );
  }
}
