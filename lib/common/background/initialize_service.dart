import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gather_here/common/location/location_manager.dart';
import 'package:gather_here/common/model/socket_model.dart';
import 'package:gather_here/common/storage/storage.dart';
import 'package:gather_here/screen/share/socket_manager.dart';

const notificationChannelId = 'my_foreground';

const notificationId = 888;

void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stopService");
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
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

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final locationManager = LocationManager();
  final storage = FlutterSecureStorage();
  final socketManager = SocketManager();
  socketManager.initialize(storage);

  final destinationLat = await storage.read(key: StorageKey.destinationLat.name);
  final destinationLng = await storage.read(key: StorageKey.destinationLng.name);

  try {
    await socketManager.connect();
    socketManager.observeConnection().listen(
          (message) {
        debugPrint('callback: $message');
      },
      onError: (error) {
        debugPrint('소켓 에러 발생: $error');
        // 재연결 시도
        socketManager.connect();
      },
    );
  } catch (e) {
    debugPrint('소켓 연결 실패: $e');
  }

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          notificationId,
          '위치 공유 중입니다.',
          '',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'MY FOREGROUND SERVICE',
              // 아이콘 추후 수정
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

      }
    }
    final position = await locationManager.getCurrentPosition();
    final distance = locationManager.calculateDistance(
      position.latitude,
      position.longitude,
      double.parse(destinationLat!),
      double.parse(destinationLng!),
    );
    debugPrint('Background service running: latitude ${position.latitude}, longitude ${position.longitude}, distance $distance');
    socketManager.deliveryMyInfo(
      SocketModel(
        type: 2,
        presentLat: position.latitude,
        presentLng: position.longitude,
        destinationDistance: distance,
      ),
    );
  });
}
