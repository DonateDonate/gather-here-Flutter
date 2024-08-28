import 'package:flutter/material.dart';

class Utils {
  void showSnackBar(BuildContext context, String message,
      {int durationSeconds = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: durationSeconds),
      ),
    );
  }

}
