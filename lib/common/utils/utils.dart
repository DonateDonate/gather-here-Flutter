import 'package:flutter/material.dart';

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
}
