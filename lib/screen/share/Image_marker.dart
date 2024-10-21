import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ImageMarker {
  static Future<Marker?> buildMarkerFromUrl({
    required String id,
    required String url,
    required LatLng position,
    required String nickname,
    int? width,
    int? height,
    Offset offset = const Offset(0.5, 0.5),
    VoidCallback? onTap,
  }) async {
    final icon =
        await getIconFromUrl(url, nickname, height: height, width: width);
    if (icon == null) return null;

    return Marker(
        markerId: MarkerId(id),
        position: position,
        icon: icon,
        anchor: offset,
        onTap: onTap);
  }

  static Future<BitmapDescriptor?> getIconFromUrl(String url, String nickname,
      {int? width, int? height}) async {
    Uint8List? bytes = await getBytesFromUrl(url, height: height, width: width);
    if (bytes == null) {
      return null;
    }

    final resizedBytes =
        await cropToCircleWithText(nickname, bytes, width ?? 100);
    if (resizedBytes == null) {
      return null;
    }

    return BitmapDescriptor.fromBytes(resizedBytes);
  }

  static Future<Uint8List?> getBytesFromUrl(String url,
      {int? width, int? height}) async {
    final cache =
        CacheManager(Config('markers', stalePeriod: const Duration(days: 3)));
    final file = await cache.getSingleFile(url);
    final bytes = await file.readAsBytes();
    return resizeImageFromBytes(bytes, width: width, height: height);
  }

  static Future<Uint8List?> resizeImageFromBytes(Uint8List bytes,
      {int? width, int? height}) async {
    Codec codec = await instantiateImageCodec(bytes,
        targetWidth: width, targetHeight: height);
    FrameInfo fi = await codec.getNextFrame();
    ByteData? data = await fi.image.toByteData(format: ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  static Future<Uint8List?> cropToCircleWithText(
      String nickname, Uint8List bytes, int size) async {
    final codec = await instantiateImageCodec(bytes,
        targetWidth: size, targetHeight: size);
    final frameInfo = await codec.getNextFrame();
    final image = frameInfo.image;

    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder,
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble() + 24));

    final double textHeight = 30.0;
    final double totalHeight = size.toDouble() + textHeight;

    final paint = Paint()..isAntiAlias = true;

    canvas.save(); // 현재 상태 저장
    final clipPath = Path()
      ..addOval(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()));
    canvas.clipPath(clipPath); // 원형 영역으로 클리핑
    canvas.drawImage(image, Offset.zero, paint); // 원형 이미지 그리기
    canvas.restore(); // 클리핑 영역을 벗어나기 위해 복원

    // 복원 후 텍스트를 그려야 잘리지 않음
    final textPainter = TextPainter(
      text: TextSpan(
        text: nickname,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: size.toDouble());
    final double textX = (size - textPainter.width) / 2;
    final double textY = size.toDouble();

    textPainter.paint(canvas, Offset(textX, textY));

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size, totalHeight.toInt());

    final byteData = await img.toByteData(format: ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
