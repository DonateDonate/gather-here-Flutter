import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationManagerProvider = Provider((ref) {
  return LocationManager();
});

class LocationManager {
  final locationSetting = Platform.isIOS ? AppleSettings(
    accuracy: LocationAccuracy.high,
    activityType: ActivityType.airborne,
    distanceFilter: 5,
    pauseLocationUpdatesAutomatically: true,
    showBackgroundLocationIndicator: true,
    allowBackgroundLocationUpdates: true,
  ) : AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
    forceLocationManager: false,
    intervalDuration: const Duration(seconds: 5)
  );

  Future<bool> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      return false;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    switch (permission) {
      case LocationPermission.whileInUse:
        return true;
      case LocationPermission.always:
        return true;
      default:
        return false;
    }
  }

  Future<Position> getCurrentPosition() async {
    final position = await Geolocator.getLastKnownPosition();

    if (position != null) {
      return position;
    }

    return await Geolocator.getCurrentPosition(locationSettings: locationSetting);
  }

  Stream<Position?> observePosition() {
    return Geolocator.getPositionStream(locationSettings: locationSetting);
  }

  double calculateDistance(
    double myLatitude,
    double myLongitude,
    double targetLatitude,
    double targetLongitude,
  ) {
    return Geolocator.distanceBetween(
      myLatitude,
      myLongitude,
      targetLatitude,
      targetLongitude,
    ).ceilToDouble();
  }
}
