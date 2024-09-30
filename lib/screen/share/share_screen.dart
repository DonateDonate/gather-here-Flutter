import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/components/default_alert_dialog.dart';
import 'package:gather_here/common/const/colors.dart';
import 'package:gather_here/common/model/response/room_response_model.dart';
import 'package:gather_here/common/model/socket_response_model.dart';
import 'package:gather_here/common/utils/utils.dart';
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
  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      ref.read(shareProvider.notifier).timeTick();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shareProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            _Map(isHost: widget.isHost, roomModel: widget.roomModel),
            _BottomSheet(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
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
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(10),
                  child: IntrinsicWidth(
                    child: Row(children: [
                      Icon(Icons.timelapse_outlined, color: AppColor.main),
                      const SizedBox(width: 10),
                      Text(
                        '${Utils.convertToDateFormat(state.remainSeconds)} 남음',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500, fontFeatures: [FontFeature.tabularFigures()]),
                      ),
                    ]),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
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

  void _setup() async {
    await ref.read(shareProvider.notifier).setInitState(widget.isHost, widget.roomModel);
    await ref.read(shareProvider.notifier).connectSocket();
    ref.read(shareProvider.notifier).observeMyLocation((lat, lon) {
      moveToTargetPosition(lat: lat, lon: lon);
    });
  }

  // 특정 위치로 카메라 포지션 이동
  void moveToTargetPosition({required double lat, required double lon}) async {
    final GoogleMapController controller = await _controller.future;
    final targetPosition = CameraPosition(target: LatLng(lat, lon), zoom: 14);
    await controller.animateCamera(CameraUpdate.newCameraPosition(targetPosition));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shareProvider);

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _defaultPosition,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onMapCreated: (controller) {
            _controller.complete(controller);
          },
          markers: state.members
              .map(
                (result) => Marker(
                  markerId: MarkerId('${result.hashCode}'),
                  position: LatLng(result.presentLat, result.presentLng),
                ),
              )
              .toSet()
              .union(
            {
              Marker(
                  markerId: MarkerId('${state.roomModel?.destinationName}'),
                  position: LatLng(state.roomModel?.destinationLat ?? 0, state.roomModel?.destinationLng ?? 0))
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: IconButton(
            onPressed: () {
              if (state.myLat != null && state.myLong != null) {
                moveToTargetPosition(lat: state.myLat!, lon: state.myLong!);
              }
            },
            icon: Icon(Icons.my_location),
          ),
        )
      ],
    );
  }
}

class _BottomSheet extends ConsumerStatefulWidget {
  const _BottomSheet({super.key});

  @override
  ConsumerState<_BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends ConsumerState<_BottomSheet> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shareProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.1,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (BuildContext context, scrollController) {
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          padding: EdgeInsets.all(20),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.roomModel?.encounterDate != null)
                          Text(
                            Utils.makeMeetingHeaderLabel(DateTime.parse(state.roomModel!.encounterDate!)),
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, height: 1),
                            maxLines: 2,
                          ),
                        const SizedBox(height: 5),
                        Text(
                          '${state.roomModel?.destinationName}',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, height: 1),
                        ),
                      ],
                    ),
                    Spacer(),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                          foregroundColor: AppColor.blue,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          )),
                      iconAlignment: IconAlignment.end,
                      label: Text('${state.roomModel?.shareCode}'),
                      icon: Icon(Icons.content_copy),
                      onPressed: () {
                        if (state.roomModel?.shareCode != null) {
                          Clipboard.setData(ClipboardData(text: state.roomModel!.shareCode!));
                        }
                      },
                    ),
                  ],
                ),
              ),
              SliverList.list(
                children: state.members.map((member) => _MemberRow(member: member)).toList(),
              )
            ],
          ),
        );
      },
    );
  }
}

class _MemberRow extends StatelessWidget {
  final SocketMemberListModel member;

  const _MemberRow({
    required this.member,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          if (member.imageUrl != "")
            ClipOval(
              child: Image.network(member.imageUrl ?? '', width: 60, height: 60, fit: BoxFit.cover),
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
                '${member.nickname}',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              Text(
                '${member.destinationDistance}m 남음',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColor.grey1),
              ),
            ],
          ),
          Spacer(),
          if (member.rank != null)
            Image.asset(
              'asset/img/crown.png',
              width: 30,
              height: 30,
              color: member.color,
              colorBlendMode: BlendMode.modulate,
            )
        ],
      ),
    );
  }
}
