import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/components/default_alert_dialog.dart';
import 'package:gather_here/common/const/colors.dart';
import 'package:gather_here/common/model/response/room_response_model.dart';
import 'package:gather_here/common/model/socket_response_model.dart';
import 'package:gather_here/common/utils/utils.dart';
import 'package:gather_here/screen/share/share_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_debounce/easy_throttle.dart';

import '../../common/background/initialize_service.dart';

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

class _ShareScreenState extends ConsumerState<ShareScreen> with WidgetsBindingObserver {
  late final Timer _timer;
  final GlobalKey<_MapState> _mapKey = GlobalKey<_MapState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      ref.read(shareProvider.notifier).timeTick();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!mounted) return;
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (!isRunning) {
        ref.read(shareProvider.notifier).disconnectOnlySocket();
        startBackgroundService();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (isRunning) {
        stopBackgroundService();
        ref.read(shareProvider.notifier).connectSocket(type: 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            _Map(isHost: widget.isHost, roomModel: widget.roomModel, key: _mapKey),
            _BottomSheet(floatingAction: _mapKey.currentState?._moveToTargetPosition),
            _backButton(),
            _timerHeader(),
          ],
        ),
      ),
    );
  }

  Widget _backButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (builder) {
                  return DefaultAlertDialog(
                    title: '위치공유를 중단할까요?',
                    content: '다시 방에 참여하기 위해선\n코드를 다시 입력해야합니다',
                    onTabConfirm: () {
                      ref.read(shareProvider.notifier).disconnectSocket();
                    },
                  );
                },
              );
            },
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Container(
              height: 50,
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.exit_to_app, size: 30),
            ),
          ),
        ),
      ),
    );
  }

  Widget _timerHeader() {
    final state = ref.watch(shareProvider);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 50,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: IntrinsicWidth(
            child: Row(
              children: [
                const Icon(Icons.timelapse_outlined, color: AppColor.black1),
                const SizedBox(width: 10),
                Text(
                  '${Utils.convertToDateFormat(state.remainSeconds)} 남음',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: state.remainSeconds <= 60 ? AppColor.red : AppColor.black1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Map extends ConsumerStatefulWidget {
  final String isHost;
  final RoomResponseModel roomModel;

  const _Map({
    required this.isHost,
    required this.roomModel,
    super.key,
  });

  @override
  ConsumerState<_Map> createState() => _MapState();
}

class _MapState extends ConsumerState<_Map> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(37.5642135, 127.0016985),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void dispose() {
    super.dispose();
    EasyThrottle.cancel('refresh');
  }

  void _setup() async {
    await ref.read(shareProvider.notifier).setInitState(widget.isHost, widget.roomModel);
    final isHost = ref.read(shareProvider).isHost == 'true';
    await ref.read(shareProvider.notifier).connectSocket(type: isHost ? 0 : 1);
    ref.read(shareProvider.notifier).observeMyLocation((lat, lon) {
      _moveToTargetPosition(lat: lat, lon: lon);
    });
  }

  // 특정 위치로 카메라 포지션 이동 (TrackingMode가 On일때만)
  void _moveToTargetPosition({required double lat, required double lon}) async {
    if (ref.read(shareProvider).isTracking) {
      final GoogleMapController controller = await _controller.future;
      final targetPosition = CameraPosition(target: LatLng(lat, lon), zoom: 16);
      await controller.animateCamera(CameraUpdate.newCameraPosition(targetPosition));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _googleMap(),
        _refreshButton(),
      ],
    );
  }

  Widget _googleMap() {
    final state = ref.watch(shareProvider);

    return GoogleMap(
      initialCameraPosition: _defaultPosition,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) {
        _controller.complete(controller);
      },
      markers: state.markers.whereType<Marker>().toSet().union({
        Marker(
          markerId: MarkerId('${state.roomModel?.destinationName}'),
          position: LatLng(state.roomModel?.destinationLat ?? 0, state.roomModel?.destinationLng ?? 0),
          infoWindow: InfoWindow(title: '${state.roomModel?.destinationName}'),
        )
      }),
    );
  }

  Widget _refreshButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: () {
              EasyThrottle.throttle('refresh', const Duration(seconds: 5), () {
                ref.read(shareProvider.notifier).deliveryMyInfo(2);
                Utils.showSnackBar(context, '화면을 새로고침 했어요');
              });
            },
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Container(
              height: 50,
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomSheet extends ConsumerStatefulWidget {
  final void Function({required double lat, required double lon})? floatingAction;

  const _BottomSheet({required this.floatingAction});

  @override
  ConsumerState<_BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends ConsumerState<_BottomSheet> {
  late final DraggableScrollableController _scrollableController;
  double _currentSheetHeight = 80;

  @override
  void initState() {
    super.initState();
    _scrollableController = DraggableScrollableController();
    _scrollableController.addListener(() {
      setState(() {
        _currentSheetHeight = _scrollableController.size * MediaQuery.of(context).size.height;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _memberListSheet(),
        _myLocationButton(),
      ],
    );
  }

  Widget _memberListSheet() {
    final state = ref.watch(shareProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.1,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      controller: _scrollableController,
      builder: (BuildContext context, scrollController) {
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(child: _destinationHeader()),
              SliverList.builder(
                itemCount: state.members.length,
                itemBuilder: (context, index) {
                  return _MemberRow(index: index, member: state.members[index]);
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _myLocationButton() {
    final state = ref.watch(shareProvider);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 10), // Smooth animation duration
      top: MediaQuery.of(context).size.height - _currentSheetHeight - 80,
      right: 10,
      child: FloatingActionButton.small(
        onPressed: () {
          Utils.showSnackBar(context, '내 위치 추적모드 ${state.isTracking ? 'off' : 'on'}', durationSeconds: 1);
          ref.read(shareProvider.notifier).toggleTrackingButton();
          if (state.myLat != null && state.myLong != null) {
            widget.floatingAction?.call(lat: state.myLat!, lon: state.myLong!);
          }
          // Button action
        },
        shape: const CircleBorder(),
        splashColor: AppColor.grey3,
        foregroundColor: state.isTracking ? AppColor.main : AppColor.black1,
        backgroundColor: AppColor.white,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _destinationHeader() {
    final state = ref.watch(shareProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.roomModel?.encounterDate != null)
          Row(
            children: [
              Text(
                Utils.makeMeetingHeaderLabel(DateTime.parse(state.roomModel!.encounterDate!)),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20, height: 1),
                maxLines: 2,
              ),
              const Spacer(),
              _copyButton(),
            ],
          ),
        const SizedBox(height: 5),
        Text(
          '${state.roomModel?.destinationName}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 24, height: 1),
        ),
      ],
    );
  }

  Widget _copyButton() {
    final state = ref.watch(shareProvider);
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: AppColor.main,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      iconAlignment: IconAlignment.end,
      label: Text('${state.roomModel?.shareCode}'),
      icon: const Icon(Icons.content_copy),
      onPressed: () {
        if (state.roomModel?.shareCode != null) {
          Clipboard.setData(ClipboardData(text: state.roomModel!.shareCode!));
        }
      },
    );
  }
}

class _MemberRow extends StatelessWidget {
  final int index;
  final SocketMemberListModel member;

  const _MemberRow({
    required this.index,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    final Color crownColor;

    switch (index) {
      case 0:
        crownColor = AppColor.gold;
      case 1:
        crownColor = AppColor.sliver;
      case 2:
        crownColor = AppColor.bronze;
      default:
        crownColor = AppColor.white;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          if (member.imageUrl != "")
            ClipOval(
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: member.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  // 로딩 중일 때 표시
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  // 에러 발생 시 표시
                  errorWidget: (context, url, error) => const Icon(Icons.account_circle),
                ),
              ),
            ),
          if (member.imageUrl == "")
            const Icon(
              Icons.account_circle,
              size: 60,
            ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.nickname,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              Text(
                '${Utils.addDistanceUnit(member.destinationDistance)} 남음',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColor.grey1),
              ),
            ],
          ),
          const Spacer(),
          if (member.rank != null)
            Image.asset(
              'asset/img/crown.png',
              width: 30,
              height: 30,
              color: crownColor,
            )
        ],
      ),
    );
  }
}
