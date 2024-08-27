import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:gather_here/common/components/default_layout.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatelessWidget {
  static get name => 'home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: 'Home',
      backgroundColor: Colors.red,
      appBarBackgroundColor: Colors.green,
      child: _Map(),//Text('Hello'),
    );
  }
}

class _Map extends StatefulWidget {
  const _Map({super.key});

  @override
  State<_Map> createState() => _MapState();
}

class _MapState extends State<_Map> {
  // final Completer<GoogleMapController> _controller =
  //     Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _kGooglePlex,
      // onMapCreated: (controller) {
      //   _controller.complete(controller);
      // },
    );
  }
}
