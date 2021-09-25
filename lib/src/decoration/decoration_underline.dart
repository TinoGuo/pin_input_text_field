part of 'pin_decoration.dart';

/// The object determine the underline color etc.
class UnderlineDecoration extends PinDecoration
    with CursorPaint
    implements SupportGap, ICursorPaint {
  /// The space between text and underline.
  final double gapSpace;

  /// The gaps between every two adjacent box, higher priority than [gapSpace].
  final List<double>? gapSpaces;

  /// The color of the underline of index character.
  final ColorBuilder colorBuilder;

  /// The height of the underline.
  final double lineHeight;

  /// The stroke cap of the underline.
  final StrokeCap? lineStrokeCap;

  /// The background color of index character.
  final ColorBuilder? bgColorBuilder;

  const UnderlineDecoration({
    TextStyle? textStyle,
    ObscureStyle? obscureStyle,
    String? errorText,
    TextStyle? errorTextStyle,
    String? hintText,
    TextStyle? hintTextStyle,
    this.gapSpace = 16.0,
    this.gapSpaces,
    required this.colorBuilder,
    this.lineHeight = 2.0,
    this.lineStrokeCap,
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
  PinEntryType get pinEntryType => PinEntryType.underline;

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
    return UnderlineDecoration(
      textStyle: textStyle ?? this.textStyle,
      obscureStyle: obscureStyle ?? this.obscureStyle,
      errorText: errorText ?? this.errorText,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      hintText: hintText ?? this.hintText,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      colorBuilder: colorBuilder,
      gapSpace: gapSpace,
      lineHeight: lineHeight,
      lineStrokeCap: lineStrokeCap,
      gapSpaces: gapSpaces,
      bgColorBuilder: this.bgColorBuilder,
    );
  }

  @override
  void notifyChange(String? pin) {
    colorBuilder.notifyChange(pin!);
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

    Paint underlinePaint = Paint()
      ..strokeWidth = lineHeight
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (lineStrokeCap != null) {
      underlinePaint.strokeCap = lineStrokeCap!;
    }

    /// Assign paint if [bgColorBuilder] is not null
    Paint? insidePaint;
    if (bgColorBuilder != null) {
      insidePaint = Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
    }

    var startX = 0.0;
    var startY = mainHeight - lineHeight;

    double gapTotalLength =
        gapSpaces?.reduce((a, b) => a + b) ?? (pinLength - 1) * gapSpace;

    List<double> actualGapSpaces =
        gapSpaces ?? List.filled(pinLength - 1, gapSpace);

    /// Calculate the width of each underline.
    double singleWidth = (size.width - gapTotalLength) / pinLength;

    for (int i = 0; i < pinLength; i++) {
      if (errorText != null && errorText!.isNotEmpty) {
        /// only draw error-color as underline-color if errorText is not null
        underlinePaint.color =
            errorTextStyle?.color ?? colorBuilder.indexProperty(i);
      } else {
        underlinePaint.color = colorBuilder.indexProperty(i);
      }
      canvas.drawLine(Offset(startX, startY),
          Offset(startX + singleWidth, startY), underlinePaint);
      if (insidePaint != null) {
        canvas.drawRect(
            Rect.fromLTWH(startX, 0, singleWidth, startY - lineHeight / 2),
            insidePaint..color = bgColorBuilder!.indexProperty(i));
      }
      startX += singleWidth + (i == pinLength - 1 ? 0 : actualGapSpaces[i]);
    }

    /// The char index of the [text]
    var index = 0;
    startX = 0.0;
    startY = 0.0;

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
      startX = singleWidth * index +
          singleWidth / 2 -
          textPainter.width / 2 +
          actualGapSpaces.take(index).sumList();
      textPainter.paint(canvas, Offset(startX, startY));
      index++;
    }

    if (cursor != null && cursor.enabled && index < pinLength) {
      drawCursor(
        canvas,
        size,
        Rect.fromLTWH(
          singleWidth * index + actualGapSpaces.take(index).sumList(),
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
            actualGapSpaces.take(index).sumList();
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
          other is UnderlineDecoration &&
          runtimeType == other.runtimeType &&
          gapSpace == other.gapSpace &&
          gapSpaces == other.gapSpaces &&
          colorBuilder == other.colorBuilder &&
          lineHeight == other.lineHeight &&
          lineStrokeCap == other.lineStrokeCap &&
          bgColorBuilder == other.bgColorBuilder;

  @override
  int get hashCode =>
      super.hashCode ^
      gapSpace.hashCode ^
      gapSpaces.hashCode ^
      colorBuilder.hashCode ^
      lineHeight.hashCode ^
      lineStrokeCap.hashCode ^
      bgColorBuilder.hashCode;

  @override
  String toString() {
    return 'UnderlineDecoration{gapSpace: $gapSpace, gapSpaces: $gapSpaces, colorBuilder: $colorBuilder, lineHeight: $lineHeight, lineStrokeCap: $lineStrokeCap, bgColorBuilder: $bgColorBuilder}';
  }
}
