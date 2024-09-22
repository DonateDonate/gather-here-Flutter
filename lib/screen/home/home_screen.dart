import 'dart:async';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/components/default_button.dart';
import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/common/components/default_text_form_field.dart';
import 'package:gather_here/common/const/colors.dart';
import 'package:gather_here/screen/debug/debug_screen.dart';
import 'package:gather_here/screen/home/home_provider.dart';
import 'package:gather_here/screen/my_page/my_page_screen.dart';
import 'package:gather_here/screen/share/share_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../common/provider/member_info_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static get name => 'home';

  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          ref.read(memberInfoProvider.notifier).getMyInfo();
        }
      },
      child: DefaultLayout(
        trailing: [
          IconButton(
            onPressed: () {
              context.goNamed(DebugScreen.name);
            },
            icon: Icon(Icons.add),
          ),
        ],
        child: Stack(
          children: [
            _Map(),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                    final result = await ref
                                        .read(homeProvider.notifier)
                                        .tapInviteButton();
                                    if (result != null) {
                                      context.pop();
                                      context.pushNamed(
                                        ShareScreen.name,
                                        pathParameters: {'isHost': 'false'},
                                        extra: result,
                                      );
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
            ),
          ],
        ),
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
  void dispose() {
    super.dispose();
    EasyDebounce.cancel('query');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberInfoProvider);
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
            context.pushNamed(MyPageScreen.name);
          },
          icon: state.memberInfoModel?.profileImageUrl != null
              ? ClipOval(
                  child: Image.network(
                  state.memberInfoModel!.profileImageUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ))
              : const Icon(
                  Icons.account_circle,
                  size: 40,
                ),
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

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(37.5642135, -127.0016985),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();

    // 현재 위치 가져온 후, 그 위치로 이동
    ref.read(homeProvider.notifier).getCurrentLocation(() {
      final vm = ref.read(homeProvider);

      if (vm.lat != null && vm.lon != null) {
        moveToTargetPosition(lat: vm.lat!, lon: vm.lon!);
      }
    });
  }

  // 특정 위치로 카메라 포지션 이동
  void moveToTargetPosition({required double lat, required double lon}) async {
    final GoogleMapController controller = await _controller.future;
    final targetPosition =
        CameraPosition(target: LatLng(lat, lon), zoom: 14.4746);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(targetPosition));
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(homeProvider);

    // 검색 결과가 바뀔때마다 카메라 이동
    ref.listen(homeProvider.select((value) => value.results), (prev, next) {
      if (prev != next && next.isNotEmpty) {
        moveToTargetPosition(lat: double.parse(next.first.y), lon: double.parse(next.first.x));
      }
    });

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _defaultPosition,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          markers: vm.results
              .map(
                (result) => Marker(
                  markerId: MarkerId('${result.hashCode}'),
                  position:
                      LatLng(double.parse(result.y), double.parse(result.x)),
                  onTap: () async {
                    ref.read(homeProvider.notifier).tapLocationMarker(result);

                    showModalBottomSheet(
                        context: context,
                        // useSafeArea: true,
                        showDragHandle: true,
                        // barrierColor: Colors.black.withAlpha(1),
                        backgroundColor: Colors.white,
                        builder: (context) {
                          return SafeArea(
                            child: Container(
                              height: 200,
                              color: Colors.white,
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${vm.selectedResult?.place_name}',
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 20),

                                  Text(
                                    '${vm.selectedResult?.road_address_name == '' ? '알 수 없는 주소' : vm.selectedResult?.road_address_name}',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                                  ),

                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      Text(
                                        '현위치로부터 ',
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        '${vm.selectedResult?.distance}m',
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 15),
                                  Spacer(),
                                  DefaultButton(
                                    title: '목적지로 설정',
                                    height: 40,
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('${MediaQuery.of(context).size.height}'),
                                            content: Container(
                                              height: 100,
                                              child: Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      // TODO: DatePicker
                                                    },
                                                    child: Text('날짜: ${vm.targetDate}'),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      // TODO: TimePicker
                                                    },
                                                    child: Text('시간: ${vm.targetTime}'),
                                                  )
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              DefaultButton(
                                                title: '위치공유 시작하기',
                                                onTap: () async {
                                                  final result =
                                                  await ref.read(homeProvider.notifier).tapStartSharingButton();
                                                  print(result);
                                                  if (result != null) {
                                                    context.pop();
                                                    context.pop();
                                                    context.pushNamed(
                                                      ShareScreen.name,
                                                      pathParameters: {'isHost': 'true'},
                                                      extra: result,
                                                    );
                                                  }
                                                },
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                ),
              )
              .toSet(),
          onMapCreated: (controller) {
            _controller.complete(controller);
          },
        ),
        Positioned(
          bottom: 100,
          left: 10,
          child: IconButton(
            onPressed: () {
              ref.read(homeProvider.notifier).getCurrentLocation(() async {
                final vm = ref.read(homeProvider);
                print('현재위치 ${vm.lat} ${vm.lon}');

                if (vm.lat != null && vm.lon != null) {
                  moveToTargetPosition(lat: vm.lat!, lon: vm.lon!);
                }
              });
            },
            icon: Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}