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

    final matrix4 = Matrix4.identity();

    matrix4.translate(.0, size.height);

    // Apparently fonts are rendered upside down, if we don't sca
    matrix4.scale(
      size.width / pathBounds.width,
      -(size.height / pathBounds.height),
    );

    canvas.drawPath(_path.transform(matrix4.storage), _paint);
  }

  @override
  bool shouldRepaint(DigitPainter oldDelegate) {
    return this._path != oldDelegate._path;
  }
}
