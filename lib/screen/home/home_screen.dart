import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/const/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_debounce/easy_debounce.dart';

import 'package:gather_here/screen/home/home_provider.dart';
import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/common/components/default_button.dart';

class HomeScreen extends StatelessWidget {
  static get name => 'home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: Colors.red,
      appBarBackgroundColor: Colors.green,
      child: Stack(
        children: [
          _Map(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  _SearchBar(),
                  Spacer(),
                  DefaultButton(
                    title: '참여하기',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// SearchBar
class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar({super.key});

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  final _searchController = SearchController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    EasyDebounce.cancel('query');
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(homeProvider);

    return SearchBar(
      backgroundColor: const WidgetStatePropertyAll(AppColor.white),
      hintText: "목적지 검색",
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(
          Icons.search,
          color: AppColor.grey1,
        ),
      ),
      trailing: [
        IconButton(
          onPressed: () {
            // TODO: 프로필 화면으로 이동하기
          },
          icon: Icon(Icons.circle),
        )
      ],
      onChanged: (text) => EasyDebounce.debounce(
        'query',
        Duration(seconds: 1),
        () async {
          ref.read(homeProvider.notifier).queryChanged(value: text);
        },
      ),
    );
  }
}

// Maps
class _Map extends StatefulWidget {
  const _Map({super.key});

  @override
  State<_Map> createState() => _MapState();
}

class _MapState extends State<_Map> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (controller) {
        _controller.complete(controller);
      },
    );
  }
}
