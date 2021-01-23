part of 'pin_decoration.dart';

/// The object determine the box stroke etc.
class BoxLooseDecoration extends PinDecoration
    with CursorPaint
    implements SupportGap {
  /// The box border radius.
  final Radius radius;

  /// The box border width.
  final double strokeWidth;

  /// The adjacent box gap.
  final double gapSpace;

  /// The gaps between every two adjacent box, higher priority than [gapSpace].
  final List<double>? gapSpaces;

  /// The box border color of index character.
  final ColorBuilder strokeColorBuilder;

  /// The background color of index character.
  final ColorBuilder? bgColorBuilder;

  const BoxLooseDecoration({
    TextStyle? textStyle,
    ObscureStyle? obscureStyle,
    String? errorText,
    TextStyle? errorTextStyle,
    String? hintText,
    TextStyle? hintTextStyle,
    this.radius: const Radius.circular(8.0),
    this.strokeWidth: 1.0,
    this.gapSpace: 16.0,
    this.gapSpaces,
    required this.strokeColorBuilder,
    this.bgColorBuilder,
  }) : super(
          textStyle: textStyle,
          obscureStyle: obscureStyle,
          errorText: errorText,
          errorTextStyle: errorTextStyle,
          hintText: hintText,
          hintTextStyle: hintTextStyle,
          bgColorBuilder: bgColorBuilder,
        );

  @override
  PinEntryType get pinEntryType => PinEntryType.boxLoose;

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
    return BoxLooseDecoration(
      textStyle: textStyle ?? this.textStyle,
      obscureStyle: obscureStyle ?? this.obscureStyle,
      errorText: errorText ?? this.errorText,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      hintText: hintText ?? this.hintText,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      strokeColorBuilder: this.strokeColorBuilder,
      strokeWidth: this.strokeWidth,
      radius: this.radius,
      gapSpace: this.gapSpace,
      gapSpaces: this.gapSpaces,
      bgColorBuilder: this.bgColorBuilder,
    );
  }

  @override
  void notifyChange(String pin) {
    strokeColorBuilder.notifyChange(pin);
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
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    double gapTotalLength =
        gapSpaces?.reduce((a, b) => a + b) ?? (pinLength - 1) * gapSpace;

    List<double> actualGapSpaces =
        gapSpaces ?? List.filled(pinLength - 1, gapSpace);

    /// Calculate the width of each underline.
    double singleWidth =
        (size.width - strokeWidth * 2 * pinLength - gapTotalLength) / pinLength;

    var startX = strokeWidth / 2;
    var startY = mainHeight - strokeWidth / 2;

    /// Assign paint if [bgColorBuilder] is not null
    Paint? insidePaint;
    if (bgColorBuilder != null) {
      insidePaint = Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
    }

    /// Draw the each rect of pin.
    for (int i = 0; i < pinLength; i++) {
      if (errorText != null && errorText!.isNotEmpty) {
        /// only draw error-color as border-color or solid-color
        /// if errorText is not null
        borderPaint.color =
            errorTextStyle?.color ?? strokeColorBuilder.indexProperty(i);
      } else {
        borderPaint.color = strokeColorBuilder.indexProperty(i);
      }
      RRect rRect = RRect.fromRectAndRadius(
          Rect.fromLTRB(
            startX,
            strokeWidth / 2,
            startX + singleWidth + strokeWidth,
            startY,
          ),
          radius);
      canvas.drawRRect(rRect, borderPaint);
      if (insidePaint != null) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(
                  startX + strokeWidth / 2,
                  strokeWidth,
                  startX + singleWidth + strokeWidth / 2,
                  startY - strokeWidth / 2,
                ),
                getInnerRadius(radius, strokeWidth)),
            insidePaint..color = bgColorBuilder!.indexProperty(i));
      }
      startX += singleWidth +
          strokeWidth * 2 +
          (i == pinLength - 1 ? 0 : actualGapSpaces[i]);
    }

    /// The char index of the [text]
    var index = 0;
    startY = 0.0;

    /// Determine whether display obscureText.
    bool obscureOn = obscureStyle != null && obscureStyle!.isTextObscure;
    TextPainter textPainter;

    text.runes.forEach((rune) {
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
      startX = singleWidth * index +
          singleWidth / 2 -
          textPainter.width / 2 +
          actualGapSpaces.take(index).sumList() +
          strokeWidth * index * 2 +
          strokeWidth;
      textPainter.paint(canvas, Offset(startX, startY));
      index++;
    });

    if (cursor != null && cursor.enabled && index < pinLength) {
      drawCursor(
        canvas,
        size,
        Rect.fromLTWH(
          singleWidth * index +
              actualGapSpaces.take(index).sumList() +
              strokeWidth * (index * 2 + 1),
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
        startX = singleWidth * index +
            singleWidth / 2 -
            textPainter.width / 2 +
            actualGapSpaces.take(index).sumList() +
            strokeWidth * index * 2 +
            strokeWidth;
        textPainter.paint(canvas, Offset(startX, startY));
        index++;
      });
    }
  }

  @override
  double get getGapWidth => gapSpace;

  @override
  List<double>? get getGapWidthList => gapSpaces;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is BoxLooseDecoration &&
          runtimeType == other.runtimeType &&
          radius == other.radius &&
          strokeWidth == other.strokeWidth &&
          gapSpace == other.gapSpace &&
          gapSpaces == other.gapSpaces &&
          strokeColorBuilder == other.strokeColorBuilder &&
          bgColorBuilder == other.bgColorBuilder;

  @override
  int get hashCode =>
      super.hashCode ^
      radius.hashCode ^
      strokeWidth.hashCode ^
      gapSpace.hashCode ^
      gapSpaces.hashCode ^
      strokeColorBuilder.hashCode ^
      bgColorBuilder.hashCode;

  @override
  String toString() {
    return 'BoxLooseDecoration{radius: $radius, strokeWidth: $strokeWidth, gapSpace: $gapSpace, gapSpaces: $gapSpaces, strokeColorBuilder: $strokeColorBuilder, bgColorBuilder: $bgColorBuilder}';
  }
}
