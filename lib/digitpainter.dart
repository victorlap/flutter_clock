import 'package:flutter/material.dart';

class DigitPainter extends CustomPainter {
  String digit;
  Path _path;
  Paint _paint;

  DigitPainter(this.digit, this._path, textColor) {
    _paint = Paint();
    _paint.color = textColor;
    _paint.style = PaintingStyle.fill;
    _paint.strokeWidth = 2.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pathBounds = _path.getBounds();

    if (pathBounds.width == 0.0 || pathBounds.height == 0.0) {
      // Prevent infinite height paintings
      return;
    }

    // Apparently fonts are rendered upside down,
    // if we don't scale them correctly.
    final pathTransform = Matrix4.identity();
    pathTransform.translate(.0, size.height);
    pathTransform.scale(
      size.width / pathBounds.width,
      -(size.height / pathBounds.height),
    );

    final scaledPath = _path.transform(pathTransform.storage);

    final shadowPaint = Paint();
    shadowPaint.color = Colors.pink[400];

    final shadowTransform = Matrix4.identity();
//    shadowTransform.translate(-size.width / 10 / 2, -size.height / 10 / 2);
//    shadowTransform.scale(1.1, 1.1);
//shadowTransform.
    canvas.drawShadow(scaledPath.transform(shadowTransform.storage),
        Colors.pink[400], 2.0, true);
//    canvas.drawPath(scaledPath.transform(shadowTransform.storage), shadowPaint);
    canvas.drawPath(scaledPath, _paint);
  }

  @override
  bool shouldRepaint(DigitPainter oldDelegate) {
    return this._path != oldDelegate._path;
  }
}
