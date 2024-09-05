import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/location/location_manager.dart';
import 'package:gather_here/common/model/room_response_model.dart';
import 'package:gather_here/common/model/socket_model.dart';
import 'package:gather_here/screen/share/socket_manager.dart';

class ShareState {
  double? myLat; // 위도
  double? myLong; // 경도
  double? distance; // 경도
  RoomResponseModel? roomModel;
  String? isHost;
  bool isConnected;

  ShareState({
    this.myLat,
    this.myLong,
    this.distance,
    this.roomModel,
    this.isHost,
    this.isConnected = false,
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
      myLat: state.myLat,
      myLong: state.myLong,
      distance: state.distance,
      roomModel: state.roomModel,
      isConnected: state.isConnected = false,
    );
  }

  void setInitState(String isHost, RoomResponseModel roomModel) async {
    state.isHost = isHost;
    state.roomModel = roomModel;
    final position = await LocationManager.getCurrentPosition();
    state.myLat = position.latitude;
    state.myLong = position.longitude;
    _setState();
  }

  void connectSocket() async {
    await socketManager.connect();
    final distance = LocationManager.calculateDistance(
      state.myLat!,
      state.myLong!,
      state.roomModel!.destinationLat,
      state.roomModel!.destinationLng,
    );
    state.distance = distance;
    _setState();
    if (state.isHost == 'true') {
      deliveryMyInfo(0);
    } else {
      deliveryMyInfo(1);
    }
  }

  void deliveryMyInfo(int type) {
    socketManager.deliveryMyInfo(
      SocketModel(
          type: type,
          presentLat: state.myLat!,
          presentLng: state.myLong!,
          destinationDistance: state.distance!),
    );
  }
  
  void setPosition(double lat, double long) {
    state.myLat = lat;
    state.myLong = long;
    final distance = LocationManager.calculateDistance(
      state.myLat!,
      state.myLong!,
      state.roomModel!.destinationLat,
      state.roomModel!.destinationLng,
    );
    state.distance = distance;
    _setState();
  }
}
