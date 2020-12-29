import 'dart:ui';

import 'package:pin_input_text_field/src/cursor/pin_cursor.dart';

abstract class ICursorPaint {
  void drawCursor(Canvas canvas, Size size, Rect rect, Cursor cursor);
}

mixin CursorPaint implements ICursorPaint {
  @override
  void drawCursor(Canvas canvas, Size size, Rect rect, Cursor cursor) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = cursor.color
      ..strokeWidth = cursor.width;
    double height = cursor.height ?? size.height / 3;

    RRect rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.center.dx - cursor.width / 2,
            rect.center.dy - height / 2, cursor.width, height),
        cursor.radius);
    canvas.drawRRect(rRect, paint);
  }
}
