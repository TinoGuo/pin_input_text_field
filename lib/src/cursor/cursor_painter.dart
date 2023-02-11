import 'dart:ui';

import 'package:pin_input_text_field/src/cursor/pin_cursor.dart';

abstract class ICursorPaint {
  void drawCursor(Canvas canvas, Size size, Rect rect, Cursor cursor,
      [Offset? offset]);
}

mixin CursorPaint implements ICursorPaint {
  late final _cursorPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  @override
  void drawCursor(Canvas canvas, Size size, Rect rect, Cursor cursor,
      [Offset? offset, TextDirection textDirection = TextDirection.ltr]) {
    double height = cursor.height ?? size.height / 3;
    double width = cursor.width ?? size.width / 3;

    _cursorPaint.color = cursor.color;

    double verticalOffset = 0;
    double horizontalOffset = 0;
    Offset effectiveOffset = Offset.zero;
    switch (cursor.orientation) {
      case Orientation.horizontal:
        if (offset != null) {
          effectiveOffset = offset + Offset(height, 0);
        }
        _cursorPaint.strokeWidth = height;
        verticalOffset = cursor.offset;
        break;
      case Orientation.vertical:
        if (offset != null) {
          effectiveOffset = offset + Offset(width, 0);
        }
        _cursorPaint.strokeWidth = width;
        horizontalOffset = cursor.offset;
        break;
    }
    if (textDirection == TextDirection.rtl) {
      effectiveOffset *= -1;
    }

    RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rect.center.dx - width / 2 - effectiveOffset.dx + horizontalOffset,
        rect.center.dy - height / 2 - effectiveOffset.dy + verticalOffset,
        width,
        height,
      ),
      cursor.radius,
    );
    canvas.drawRRect(rRect, _cursorPaint);
  }
}
