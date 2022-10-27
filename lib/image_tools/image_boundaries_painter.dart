import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

class ImageBoundariesPainter extends CustomPainter {
  ImageBoundariesPainter(this.boundaries, this.absoluteImageSize);

  final List<Point> boundaries;
  final Size absoluteImageSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (boundaries.length < 4) {
      return;
    }


    final paint = Paint();
    paint.strokeWidth = 6;

    canvas.drawPoints(PointMode.polygon, boundaries.map((p) => Offset(p.x.toDouble(), p.y.toDouble())).toList(), paint);
  }

  @override
  bool shouldRepaint(covariant ImageBoundariesPainter oldDelegate) {
    return boundaries != oldDelegate.boundaries || absoluteImageSize != oldDelegate.absoluteImageSize;
  }

}
