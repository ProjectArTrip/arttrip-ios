import 'dart:ui' as ui;

import 'package:arttrip/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapClusterRenderer {
  const MapClusterRenderer._();

  /// 클러스터 마커 BitmapDescriptor 생성 (어두운 원형 + 흰색 숫자)
  static Future<BitmapDescriptor> buildClusterBitmap(
    int count, {
    double devicePixelRatio = 2.0,
  }) async {
    // Figma 스펙: 5건→33dp, 12건→40dp, 24건+→60dp
    final double logicalSize;
    final double fontSize;
    if (count <= 5) {
      logicalSize = 33;
      fontSize = 9;
    } else if (count < 20) {
      logicalSize = 40;
      fontSize = 10;
    } else {
      logicalSize = 60;
      fontSize = 14;
    }

    final pixelSize = (logicalSize * devicePixelRatio).ceil();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = pixelSize / 2;

    // 원형 배경 (rgba(17, 17, 17, 0.8))
    final paint = Paint()..color = AppColors.gray900.withValues(alpha: 0.8);
    canvas.drawCircle(Offset(center, center), center, paint);

    // 숫자 텍스트
    final textPainter = TextPainter(
      text: TextSpan(
        text: count.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize * devicePixelRatio,
          fontWeight: FontWeight.w700,
          fontFamily: 'Pretendard',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (pixelSize - textPainter.width) / 2,
        (pixelSize - textPainter.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(pixelSize, pixelSize);
    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      imagePixelRatio: devicePixelRatio,
    );
  }

  /// 개별 마커 BitmapDescriptor 생성 (보라색 원형 핀)
  static Future<BitmapDescriptor> buildPinBitmap({
    double devicePixelRatio = 2.0,
  }) async {
    const logicalSize = 14.0;
    final pixelSize = (logicalSize * devicePixelRatio).ceil();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = pixelSize / 2;

    // 보라색 원형
    final paint = Paint()..color = AppColors.primary300;
    canvas.drawCircle(Offset(center, center), center, paint);

    // 흰색 테두리
    final borderWidth = 2.0 * devicePixelRatio;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawCircle(
      Offset(center, center),
      center - borderWidth / 2,
      borderPaint,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(pixelSize, pixelSize);
    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      imagePixelRatio: devicePixelRatio,
    );
  }
}
