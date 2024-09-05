import 'package:geolocator/geolocator.dart';

class LocationManager {
  static final locationSetting = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  static Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission;

    if (!serviceEnabled) {
      return Future.error('위치서비스를 사용할 수 없음');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치권한 요청이 거부됨');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치권한 요청이 영원히 거부됨');
    }

    return await Geolocator.getCurrentPosition(locationSettings: locationSetting);
  }

  static Stream<Position?> observePosition() {
    return Geolocator.getPositionStream(locationSettings: locationSetting);
  }
}