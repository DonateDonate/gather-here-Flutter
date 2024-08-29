import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/components/default_text_form_field.dart';
import 'package:gather_here/common/const/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_debounce/easy_debounce.dart';

import 'package:gather_here/screen/home/home_provider.dart';
import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/common/components/default_button.dart';

class HomeScreen extends ConsumerWidget {
  static get name => 'home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultLayout(
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
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('참여코드를 입력해주세요'),
                            content: DefaultTextFormField(
                              label: '4자리 코드를 입력해주세요',
                              onChanged: (text) => ref
                                  .read(homeProvider.notifier)
                                  .inviteCodeChanged(value: text),
                            ),
                            actions: [
                              DefaultButton(
                                title: '확인',
                                onTap: () async {
                                  final result = await ref.read(homeProvider.notifier).tapInviteButton();
                                  if (result) {
                                    context.pop();
                                  } else {
                                    print('Error: 방입장 실패');
                                  }
                                },
                              )
                            ],
                          );
                        },
                      );
                    },
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
class _Map extends ConsumerStatefulWidget {
  const _Map({super.key});

  @override
  ConsumerState<_Map> createState() => _MapState();
}

class _MapState extends ConsumerState<_Map> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();

    ref.read(homeProvider.notifier).getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(homeProvider);

    return GoogleMap(
      initialCameraPosition: _kGooglePlex,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      markers: vm.results
          .map(
            (result) => Marker(
              markerId: MarkerId('${result.hashCode}'),
              position: LatLng(double.parse(result.y), double.parse(result.x)),
              onTap: () {
                print(result.toString());
              },
            ),
          )
          .toSet(),
      onMapCreated: (controller) {
        _controller.complete(controller);
      },
    );
  }
}
