part of 'pin_decoration.dart';

/// The object determine the box stroke etc.
class BoxTightDecoration extends PinDecoration with CursorPaint {
  /// The box border width.
  final double strokeWidth;

  /// The box border radius.
  final Radius radius;

  /// The box border color.
  final Color strokeColor;

  /// The background color of index character
  final ColorBuilder? bgColorBuilder;

  const BoxTightDecoration({
    TextStyle? textStyle,
    ObscureStyle? obscureStyle,
    String? errorText,
    TextStyle? errorTextStyle,
    String? hintText,
    TextStyle? hintTextStyle,
    this.strokeWidth = 1.0,
    this.radius = const Radius.circular(8.0),
    this.strokeColor = Colors.cyan,
    this.bgColorBuilder,
  }) : super(
          textStyle: textStyle,
          obscureStyle: obscureStyle,
          errorText: errorText,
          errorTextStyle: errorTextStyle,
          hintText: hintText,
          hintTextStyle: hintTextStyle,
          baseBgColorBuilder: bgColorBuilder,
        );

  @override
  PinEntryType get pinEntryType => PinEntryType.boxTight;

  @override
  PinDecoration copyWith({
    TextStyle? textStyle,
    ObscureStyle? obscureStyle,
    String? errorText,
    TextStyle? errorTextStyle,
    String? hintText,
    TextStyle? hintTextStyle,
    ColorBuilder? bgColorBuilder,
  }) {
    return BoxTightDecoration(
      textStyle: textStyle ?? this.textStyle,
      obscureStyle: obscureStyle ?? this.obscureStyle,
      errorText: errorText ?? this.errorText,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      hintText: hintText ?? this.hintText,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      radius: radius,
      bgColorBuilder: this.bgColorBuilder,
    );
  }

  @override
  void notifyChange(String pin) {
    bgColorBuilder?.notifyChange(pin);
  }

  @override
  void drawPin(
    Canvas canvas,
    Size size,
    String text,
    int pinLength,
    Cursor? cursor,
  ) {
    /// Calculate the height of paint area for drawing the pin field.
    /// it should honor the error text (if any) drawn by
    /// the actual texfield behind.
    /// but, since we can access the drawn textfield behind from here,
    /// we use a simple logic to calculate it.
    double mainHeight;
    if (errorText != null && errorText!.isNotEmpty) {
      mainHeight = size.height - (errorTextStyle?.fontSize ?? 0 + 8.0);
    } else {
      mainHeight = size.height;
    }

    Paint borderPaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    /// Assign paint if [solidColor] is not null
    Paint? insidePaint;
    if (bgColorBuilder != null) {
      insidePaint = Paint()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
    }

    Rect rect = Rect.fromLTRB(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth / 2,
      mainHeight - strokeWidth / 2,
    );

    /// Draw the whole rect.
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), borderPaint);

    /// Calculate the width of each underline.
    double singleWidth =
        (size.width - strokeWidth * (pinLength + 1)) / pinLength;

    for (int i = 0; i < pinLength; i++) {
      if (insidePaint != null) {
        var corners = _getCorner(i, pinLength);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(
              singleWidth * i + strokeWidth * (i + 1),
              strokeWidth,
              singleWidth,
              mainHeight - strokeWidth * 2,
            ),
            topLeft: corners[0],
            topRight: corners[1],
            bottomRight: corners[2],
            bottomLeft: corners[3],
          ),
          insidePaint..color = bgColorBuilder!.indexProperty(i),
        );
      }
      if (i == 0) continue;
      double offsetX = singleWidth +
          strokeWidth * i +
          strokeWidth / 2 +
          singleWidth * (i - 1);
      canvas.drawLine(Offset(offsetX, strokeWidth),
          Offset(offsetX, mainHeight - strokeWidth), borderPaint);
    }

    /// The char index of the [text]
    var index = 0;
    var startY = 0.0;
    var startX = 0.0;

    /// Determine whether display obscureText.
    bool obscureOn = obscureStyle != null && obscureStyle!.isTextObscure;
    TextPainter textPainter;

    for (var rune in text.runes) {
      String code;
      if (obscureOn) {
        code = obscureStyle!.obscureText;
      } else {
        code = String.fromCharCode(rune);
      }
      textPainter = TextPainter(
        text: TextSpan(
          style: textStyle,
          text: code,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      /// Layout the text.
      textPainter.layout();

      /// No need to compute again
      if (startY == 0.0) {
        startY = mainHeight / 2 - textPainter.height / 2;
      }
      startX = strokeWidth * (index + 1) +
          singleWidth * index +
          singleWidth / 2 -
          textPainter.width / 2;
      textPainter.paint(canvas, Offset(startX, startY));
      index++;
    }

    if (cursor != null && cursor.enabled && index < pinLength) {
      drawCursor(
        canvas,
        size,
        Rect.fromLTWH(
          singleWidth * index + strokeWidth * index,
          0,
          singleWidth,
          size.height,
        ),
        cursor,
      );
    } else if (hintText != null) {
      hintText!.substring(index).runes.forEach((rune) {
        String code = String.fromCharCode(rune);
        textPainter = TextPainter(
          text: TextSpan(
            style: hintTextStyle,
            text: code,
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        /// Layout the text.
        textPainter.layout();

        startY = mainHeight / 2 - textPainter.height / 2;
        startX = strokeWidth * (index + 1) +
            singleWidth * index +
            singleWidth / 2 -
            textPainter.width / 2;
        textPainter.paint(canvas, Offset(startX, startY));
        index++;
      });
    }
  }

  List<Radius> _getCorner(int index, int pinLength) {
    if (index == 0) {
      var innerRadius = getInnerRadius(radius, strokeWidth);
      return [innerRadius, Radius.zero, Radius.zero, innerRadius];
    } else if (index == pinLength - 1) {
      var innerRadius = getInnerRadius(radius, strokeWidth);
      return [Radius.zero, innerRadius, innerRadius, Radius.zero];
    } else {
      return List.filled(4, Radius.zero);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is BoxTightDecoration &&
          runtimeType == other.runtimeType &&
          strokeWidth == other.strokeWidth &&
          radius == other.radius &&
          strokeColor == other.strokeColor &&
          bgColorBuilder == other.bgColorBuilder;

  @override
  int get hashCode =>
      super.hashCode ^
      strokeWidth.hashCode ^
      radius.hashCode ^
      strokeColor.hashCode ^
      bgColorBuilder.hashCode;

  @override
  String toString() {
    return 'BoxTightDecoration{strokeWidth: $strokeWidth, radius: $radius, strokeColor: $strokeColor, bgColorBuilder: $bgColorBuilder}';
  }
}
