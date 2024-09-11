import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/model/response/room_response_model.dart';
import 'package:gather_here/screen/share/share_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() async {
    await ref.read(shareProvider.notifier).setInitState(widget.isHost, widget.roomModel);
    await ref.read(shareProvider.notifier).connectSocket();
    ref.read(shareProvider.notifier).observeMyLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _Map(),
          SafeArea(
              child: Container(
            color: Colors.red,
            width: double.infinity,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text('09:00 남음'),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                Positioned(
                  right: 16, // 오른쪽 끝에서 약간의 여백을 줌
                  child: IconButton(
                    onPressed: () {
                      ref.read(shareProvider.notifier).disconnectSocket();
                      context.pop();
                    },
                    icon: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.exit_to_app,
                          size: 24,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}

class _Map extends ConsumerStatefulWidget {
  const _Map({super.key});

  @override
  ConsumerState<_Map> createState() => _MapState();
}

class _MapState extends ConsumerState<_Map> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(37.5642135, -127.0016985),
    zoom: 14.4746,
  );

  // 특정 위치로 카메라 포지션 이동
  void moveToTargetPosition({required double lat, required double lon}) async {
    final GoogleMapController controller = await _controller.future;
    final targetPosition = CameraPosition(target: LatLng(lat, lon), zoom: 14.4746);
    await controller.animateCamera(CameraUpdate.newCameraPosition(targetPosition));
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(shareProvider);
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _defaultPosition,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onMapCreated: (controller) {
            _controller.complete(controller);
          },
          markers: vm.members
              .map(
                (result) => Marker(
              markerId: MarkerId('${result.hashCode}'),
              position:
              LatLng(result.presentLat, result.presentLng),
            ),
          )
              .toSet(),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: IconButton(
            onPressed: () {
              if (vm.myLat != null && vm.myLong != null) {
                moveToTargetPosition(lat: vm.myLat!, lon: vm.myLong!);
              }
            },
            icon: Icon(Icons.my_location),
          ),
        )
      ],
    );
  }
}
