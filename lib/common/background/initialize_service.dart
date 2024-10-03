import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gather_here/common/location/location_manager.dart';
import 'package:gather_here/common/model/socket_model.dart';
import 'package:gather_here/screen/share/socket_manager.dart';

late SocketManager _socketManager;
late LocationManager _locationManager;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  final storage = FlutterSecureStorage();
  _socketManager = SocketManager(storage: storage);
  _locationManager = LocationManager();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: '위치 공유 중',
      initialNotificationContent: '백그라운드에서 위치를 공유하고 있습니다',
      foregroundServiceNotificationId: 888,
    ),
  );

  await service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      print('setAsForeground');
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      print('setAsBackground');
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    print('stopService');
    _socketManager.close();
    service.stopSelf();
  });

  await _socketManager.connect();

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: '위치 공유 중',
          content: '백그라운드에서 위치를 공유하고 있습니다.',
        );
      }
    }

    final position = await _locationManager.getCurrentPosition();
    final socketModel = SocketModel(
      type: 2,
      presentLat: position.latitude,
      presentLng: position.longitude,
      destinationDistance: 0,
    );
    _socketManager.deliveryMyInfo(socketModel);

    service.invoke(
      'update',
      {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
    );
  });
}
