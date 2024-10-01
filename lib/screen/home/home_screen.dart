import 'dart:async';
import 'package:flutter/material.dart';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/utils/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:gather_here/common/components/default_button.dart';
import 'package:gather_here/common/components/default_date_dialog.dart';
import 'package:gather_here/common/components/default_layout.dart';
import 'package:gather_here/common/components/default_text_field_dialog.dart';
import 'package:gather_here/common/const/colors.dart';
import 'package:gather_here/screen/home/home_provider.dart';
import 'package:gather_here/screen/my_page/my_page_screen.dart';
import 'package:gather_here/screen/share/share_screen.dart';
import '../../common/model/response/search_response_model.dart';
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
    final room = await ref.read(homeProvider.notifier).getRoomInfo();

    // room 정보가 있다면 shareScreen 으로 이동
    if (room.roomSeq != null && mounted) {
      context.pushNamed(
        ShareScreen.name,
        pathParameters: {'isHost': 'false'},
        extra: room,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Stack(
        children: [
          const _Map(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  const _SearchBar(),
                  const Spacer(),
                  DefaultButton(
                    title: '참여하기',
                    onTap: () {
                      _showInviteCodeDialog(context);
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

  // 초대코드입력 dialog보여주기
  void _showInviteCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return DefaultTextFieldDialog(
          title: '참여코드를 입력해주세요',
          labels: const ['4자리 코드를 입력해주세요'],
          onChanged: (text) async {
            ref.read(homeProvider.notifier).inviteCodeChanged(value: text[0]);
            final result = await ref.read(homeProvider.notifier).tapInviteButton();

            if (result != null) {
              context.pop();
              context.pushNamed(
                ShareScreen.name,
                pathParameters: {'isHost': 'false'},
                extra: result,
              );
            } else {
              Utils.showSnackBar(context, 'ERROR: 방 입장에 실패했습니다');
            }
          },
        );
      },
    );
  }
}

// SearchBar
class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  @override
  void dispose() {
    super.dispose();
    EasyDebounce.cancel('query');
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      backgroundColor: const WidgetStatePropertyAll(AppColor.white),
      hintText: "목적지 검색",
      leading: _leadingIcon(),
      trailing: [_trailingIcon()],
      onChanged: (text) => EasyDebounce.debounce(
        'query',
        const Duration(seconds: 1),
        () async {
          ref.read(homeProvider.notifier).queryChanged(value: text);
        },
      ),
    );
  }

  Widget _leadingIcon() {
    return const Padding(
      padding: EdgeInsets.only(left: 8),
      child: Icon(
        Icons.search,
        color: AppColor.grey1,
      ),
    );
  }

  Widget _trailingIcon() {
    final state = ref.watch(memberInfoProvider);

    return IconButton(
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
    );
  }
}

// Maps
class _Map extends ConsumerStatefulWidget {
  const _Map();

  @override
  ConsumerState<_Map> createState() => _MapState();
}

class _MapState extends ConsumerState<_Map> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  late BitmapDescriptor _defaultMarker;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(37.5642135, -127.0016985),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();

    _setup();
  }

  void _setup() async {
    // defaultMarker UI설정
    _defaultMarker = await ref.read(homeProvider.notifier).createCustomMarkerBitmap('');
    // 현재위치로 지도 이동시키기
    ref.read(homeProvider.notifier).getCurrentLocation(() {
      final state = ref.read(homeProvider);

      if (state.lat != null && state.lon != null) {
        _moveToTargetPosition(lat: state.lat!, lon: state.lon!);
      }
    });
  }

  // CustomMarker 그리기
  Future<void> _loadCustomMarkers(List<SearchDocumentsModel> results) async {
    for (final result in results) {
      final marker = await ref.read(homeProvider.notifier).createCustomMarkerBitmap(result.place_name!);
      // setState(() {
      result.markerIcon = marker;
      // });
    }
  }

  // 특정 위치로 카메라 포지션 이동
  void _moveToTargetPosition({required double lat, required double lon}) async {
    final GoogleMapController controller = await _controller.future;
    final targetPosition = CameraPosition(target: LatLng(lat, lon), zoom: 14.4746);
    await controller.animateCamera(CameraUpdate.newCameraPosition(targetPosition));
  }

  // 검색 결과가 바뀔 때마다 카메라 이동, 마커 변경
  void _observeLocation(BuildContext superContext) {
    ref.listen(homeProvider.select((value) => value.results), (prev, next) async {
      if (prev != next && next.isNotEmpty) {
        _moveToTargetPosition(lat: double.parse(next.first.y), lon: double.parse(next.first.x));

        await _loadCustomMarkers(next);

        showModalBottomSheet(
          context: superContext,
          showDragHandle: true,
          backgroundColor: Colors.white,
          barrierColor: Colors.black.withAlpha(1),
          isScrollControlled: true,
          builder: (context) {
            return _LocationListSheet(
              locations: next,
              moveToPositionAction: (lat, lng) {
                _moveToTargetPosition(lat: lat, lon: lng);
              },
              showSelectedLocation: () {
                showModalBottomSheet(
                  context: superContext,
                  showDragHandle: true,
                  backgroundColor: Colors.white,
                  builder: (context) {
                    return const _SelectedLocationSheet();
                  },
                );
              },
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _observeLocation(context);

    return Stack(
      children: [
        _googleMap(),
        _currentLocationButton(),
      ],
    );
  }

  // 구굴맵
  Widget _googleMap() {
    final state = ref.watch(homeProvider);

    return GoogleMap(
      initialCameraPosition: _defaultPosition,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      markers: state.results.map(
        (result) {
          final isSelected = result == state.selectedResult;
          return Marker(
            markerId: MarkerId('${result.hashCode}'),
            position: LatLng(double.parse(result.y), double.parse(result.x)),
            icon: isSelected ? BitmapDescriptor.defaultMarker : (result.markerIcon ?? _defaultMarker),
            infoWindow: InfoWindow(title: result.place_name),
            onTap: () async {
              ref.read(homeProvider.notifier).tapLocationMarker(result);

              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                backgroundColor: Colors.white,
                builder: (context) {
                  return const _SelectedLocationSheet();
                },
              );
            },
          );
        },
      ).toSet(),
      onMapCreated: (controller) {
        _controller.complete(controller);
      },
    );
  }

  // 현재위치 버튼
  Widget _currentLocationButton() {
    return Positioned(
      bottom: 100,
      left: 10,
      child: IconButton(
        onPressed: () {
          ref.read(homeProvider.notifier).getCurrentLocation(() async {
            final homeState = ref.read(homeProvider);
            debugPrint('현재위치 ${homeState.lat} ${homeState.lon}');

            if (homeState.lat != null && homeState.lon != null) {
              _moveToTargetPosition(lat: homeState.lat!, lon: homeState.lon!);
            }
          });
        },
        icon: const Icon(Icons.my_location),
      ),
    );
  }
}

// 검색 완료시 나오는 장소들 BottomSheet
class _LocationListSheet extends ConsumerWidget {
  final List<SearchDocumentsModel> locations;
  final VoidCallback showSelectedLocation;
  final void Function(double, double) moveToPositionAction;

  const _LocationListSheet({
    required this.locations,
    required this.showSelectedLocation,
    required this.moveToPositionAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: ListView.separated(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final result = locations[index];
              return _rowItem(context, ref, result);
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
          ),
        ),
      ),
    );
  }

  Widget _rowItem(BuildContext context, WidgetRef ref, SearchDocumentsModel result) {
    return InkWell(
      onTap: () async {
        moveToPositionAction(double.parse(result.y), double.parse(result.x));
        ref.read(homeProvider.notifier).tapLocationMarker(result);
        context.pop();

        await Future.delayed(const Duration(milliseconds: 500));
        showSelectedLocation();
      },
      child: ListTile(
        title: Text(
          result.place_name ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text('${result.distance}m'),
      ),
    );
  }
}

// 장소 선택 됬을때 나오는 BottomSheet
class _SelectedLocationSheet extends ConsumerWidget {
  const _SelectedLocationSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return SafeArea(
      child: Container(
        height: 200,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${state.selectedResult?.place_name}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Text(
              '${state.selectedResult?.road_address_name == '' ? '알 수 없는 주소' : state.selectedResult?.road_address_name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  '현위치로부터 ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                Text(
                  '${state.selectedResult?.distance}m',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Spacer(),
            _defaultButton(context, ref),
          ],
        ),
      ),
    );
  }

  // 목적지로 설정하기 버튼
  Widget _defaultButton(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return DefaultButton(
      title: '목적지로 설정',
      height: 40,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return DefaultDateDialog(
              destination: state.selectedResult!.place_name!,
              onTab: (dateTime, timeOfDay) async {
                final result = await ref.read(homeProvider.notifier).tapStartSharingButton(dateTime, timeOfDay);

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
    );
  }
}
