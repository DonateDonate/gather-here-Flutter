import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/location/location_manager.dart';
import 'package:gather_here/common/model/room_response_model.dart';
import 'package:gather_here/common/model/socket_model.dart';
import 'package:gather_here/screen/share/socket_manager.dart';

class ShareState {
  double? latitude; // 위도
  double? longitude; // 경도
  double? distance; // 경도
  RoomResponseModel? roomModel;
  bool? isHost;

  ShareState({
    this.latitude,
    this.longitude,
    this.distance,
    this.roomModel,
    this.isHost,
  });
}

final shareProvider =
    AutoDisposeStateNotifierProvider<ShareProvider, ShareState>((ref) {
  final socketManage = ref.watch(socketManagerProvider);
  return ShareProvider(socketManager: socketManage);
});

class ShareProvider extends StateNotifier<ShareState> {
  final SocketManager socketManager;

  ShareProvider({
    required this.socketManager,
  }) : super(ShareState()) {}

  void _setState() {
    state = ShareState(
      isHost: state.isHost,
      latitude: state.latitude,
      longitude: state.longitude,
      distance: state.distance,
    );
  }

  void setInitState(bool isHost, RoomResponseModel roomModel) async {
    state.isHost = isHost;
    state.roomModel = roomModel;
    final position = await LocationManager.getCurrentPosition();
    state.latitude = position.latitude;
    state.longitude = position.longitude;
    _setState();
  }

  void connectSocket() async {
    await socketManager.connect();
    final distance = LocationManager.calculateDistance(
      state.latitude!,
      state.longitude!,
      state.roomModel!.destinationLat,
      state.roomModel!.destinationLng,
    );
    state.distance = distance;
    if (state.isHost == true) {
      deliveryMyInfo(0);
    } else {
      deliveryMyInfo(1);
    }
  }

  void deliveryMyInfo(int type) {
    socketManager.deliveryMyInfo(
      SocketModel(
          type: type,
          presentLat: state.latitude!,
          presentLng: state.longitude!,
          destinationDistance: state.distance!),
    );
  }
}
