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

    final scaleHeight = size.width / absoluteImageSize.height;
    print(scaleHeight);
    final scaleWidth = size.height / absoluteImageSize.width;
    print(scaleWidth);



    final paint = Paint();
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 6;
    final offsets = boundaries.map((p) => Offset(p.x.toDouble() * scaleWidth, p.y.toDouble() * scaleHeight)).toList();
    offsets.sort((a, b) => a.dy.compareTo(b.dy));
    final top = offsets.sublist(0, 2);
    final bottom = offsets.sublist(2);
    top.sort((a, b) => a.dx.compareTo(b.dx));
    bottom.sort((a, b) => b.dx.compareTo(a.dx));
    final sortedOffsets = top..addAll(bottom)..add(top.first);

    canvas.drawPoints(PointMode.polygon, sortedOffsets, paint);

  }

  @override
  bool shouldRepaint(covariant ImageBoundariesPainter oldDelegate) {
    return boundaries != oldDelegate.boundaries || absoluteImageSize != oldDelegate.absoluteImageSize;
  }

}
