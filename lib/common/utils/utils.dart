import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  Utils._();

  // snackBar 보여주기
  static void showSnackBar(BuildContext context, String message, {int durationSeconds = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: durationSeconds),
      ),
    );
  }

  // 초를 00:00:00 형태로 변환
  static String convertToDateFormat(int remainSecond) {
    final hour = remainSecond ~/ 3600;
    final minute = (remainSecond % 3600) ~/ 60;
    final second = remainSecond % 60;

    if (hour != 0) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2,'0')}';
    } else {
      return '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2,'0')}';
    }
  }

  /*
    만날 시간 표시
    ex) 오늘(내일) 19시 14분 까지
   */
  static String makeMeetingHeaderLabel(DateTime destinationDate) {
    final now = DateTime.now();

    final hour = destinationDate.hour.toString().padLeft(2, '0');
    final minute = destinationDate.minute.toString().padLeft(2, '0');

    if (now.day == destinationDate.day) {
      return '오늘 $hour시 $minute분 까지';
    } else {
      return '내일 $hour시 $minute분 까지';
    }
  }

  static Future<void> requestNotificationPermission() async {
    await Permission.notification.request();
  }

  static Future<File> compressImage(File imageFile) async {
    Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage != null) {
      img.Image resizedImage = img.copyResize(decodedImage, width: 800, height: 800);
      Uint8List compressedImageBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: 30));

      final compressedImageFile = File(imageFile.path)..writeAsBytesSync(compressedImageBytes);
      return compressedImageFile;
    } else {
      throw Exception("이미지 디코딩 실패");
    }
  }

  /*
  900 -> 900m
  2300 -> 2.3km
   */
  static String addDistanceUnit(double meters) {
    final km = meters / 1000;

    if (meters < 1000) {
      return '${meters}m';
    } else {
      return '${km.toStringAsFixed(1)}km';
    }
  }
}
