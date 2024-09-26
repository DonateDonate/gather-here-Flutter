import 'dart:async';
import 'dart:ui' as ui;

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/components/default_button.dart';
import 'package:gather_here/common/components/default_date_dialog.dart';
import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/common/components/default_text_field_dialog.dart';
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

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() async {
    final result = await ref.read(homeProvider.notifier).getRoomInfo();
    if (result != null && result.roomSeq != null) {
      context.pushNamed(
        ShareScreen.name,
        pathParameters: {'isHost': 'false'},
        extra: result,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
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
                          return DefaultTextFieldDialog(
                            title: '참여코드를 입력해주세요',
                            labels: const ['4자리 코드를 입력해주세요'],
                            onChanged: (text) async {
                              ref
                                  .read(homeProvider.notifier)
                                  .inviteCodeChanged(value: text[0]);
                              final result = await ref.read(homeProvider.notifier).tapInviteButton();
                              if (result != null) {
                                context.pop();
                                context.pushNamed(
                                  ShareScreen.name,
                                  pathParameters: {'isHost': 'false'},
                                  extra: result,
                                );
                              } else {
                                debugPrint('Error: 방입장 실패');
                              }
                            },
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

  BitmapDescriptor? _defaultMarker;
  BitmapDescriptor? _focusedMarker;

  @override
  void initState() {
    super.initState();
    _createMarkerIcons();

    // 현재 위치 가져온 후, 그 위치로 이동
    ref.read(homeProvider.notifier).getCurrentLocation(() {
      final state = ref.read(homeProvider);

      if (state.lat != null && state.lon != null) {
        moveToTargetPosition(lat: state.lat!, lon: state.lon!);
      }
    });
  }

  Future<void> _createMarkerIcons() async {
    _defaultMarker = await _createMarkerIcon(Colors.red, 40);
    _focusedMarker =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    setState(() {});
  }

  /// PictureRecorder는 그래픽 작업을 기록하는 객체
  /// 메모리에 그래픽 작업을 저장하여 나중에 이미지로 변환가능
  /// Canvas를 통해 실제로 그리기 작업을 함
  /// Paint는 그리기 작업의 스타일을 설정
  /// drawCircle로 원을 그리고 Offset(size / 2, size / 2)를 하면 원의 중심점을 정의함
  /// endRecording()으로 그리기 작업을 종료하고 toImage로 이미지로 변환
  Future<BitmapDescriptor> _createMarkerIcon(Color color, double size) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);
    final img = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
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
    final state = ref.watch(homeProvider);

    // 검색 결과가 바뀔 때마다 카메라 이동
    ref.listen(homeProvider.select((value) => value.results), (prev, next) {
      if (prev != next && next.isNotEmpty) {
        moveToTargetPosition(
            lat: double.parse(next.first.y), lon: double.parse(next.first.x));
      }
    });

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _defaultPosition,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          markers: state.results.map((result) {
            final isSelected = result == state.selectedResult;
            return Marker(
              markerId: MarkerId('${result.hashCode}'),
              position: LatLng(double.parse(result.y), double.parse(result.x)),
              icon: isSelected
                  ? (_focusedMarker ?? BitmapDescriptor.defaultMarker)
                  : (_defaultMarker ?? BitmapDescriptor.defaultMarker),
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
                              '${state.selectedResult?.place_name}',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${state.selectedResult?.road_address_name == '' ? '알 수 없는 주소' : state.selectedResult?.road_address_name}',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text(
                                  '현위치로부터 ',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  '${state.selectedResult?.distance}m',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700),
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
                                    return DefaultDateDialog(
                                      destination:
                                          state.selectedResult!.place_name!,
                                      // targetDate: homeState.targetDate,
                                      // targetTime: homeState.targetTime,
                                      onTab: (dateTime, timeOfDay) async {
                                        final result = await ref
                                            .read(homeProvider.notifier)
                                            .tapStartSharingButton(
                                              dateTime,
                                              timeOfDay,
                                            );
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
                                    );
                                  },
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }).toSet(),
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
                final homeState = ref.read(homeProvider);
                print('현재위치 ${homeState.lat} ${homeState.lon}');

                if (homeState.lat != null && homeState.lon != null) {
                  moveToTargetPosition(
                      lat: homeState.lat!, lon: homeState.lon!);
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
