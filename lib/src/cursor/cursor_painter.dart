import 'dart:ui';

import 'package:pin_input_text_field/src/cursor/pin_cursor.dart';

abstract class ICursorPaint {
  void drawCursor(Canvas canvas, Size size, Rect rect, Cursor cursor,
      [Offset? offset]);
}

mixin CursorPaint implements ICursorPaint {
  @override
  void drawCursor(Canvas canvas, Size size, Rect rect, Cursor cursor,
      [Offset? offset, TextDirection textDirection = TextDirection.ltr]) {
    Offset effectiveOffset = Offset.zero;
    if (offset != null) {
      effectiveOffset = offset + Offset(cursor.width, 0);
    }
    if (textDirection == TextDirection.rtl) {
      effectiveOffset *= -1;
    }

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = cursor.color
      ..strokeWidth = cursor.width;
    double height = cursor.height ?? size.height / 3;

    RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rect.center.dx - cursor.width / 2 - effectiveOffset.dx,
        rect.center.dy - height / 2 - effectiveOffset.dy,
        cursor.width,
        height,
      ),
      cursor.radius,
    );
    canvas.drawRRect(rRect, paint);
  }
}
