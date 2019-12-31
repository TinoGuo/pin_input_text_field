part of 'pin_decoration.dart';

class CirclePinDecoration extends PinDecoration implements SupportGap {
  /// The box border width.
  final double strokeWidth;

  /// The adjacent box gap.
  final double gapSpace;

  /// The gaps between every two adjacent box, higher priority than [gapSpace].
  final List<double> gapSpaces;

  /// The box border color.
  final Color strokeColor;

  /// The box inside solid color, sometimes it equals to the box background.
  final Color solidColor;

  /// The border changed color when user enter pin.
  final Color enteredColor;

  const CirclePinDecoration({
    TextStyle textStyle,
    ObscureStyle obscureStyle,
    String errorText,
    TextStyle errorTextStyle,
    String hintText,
    TextStyle hintTextStyle,
    this.gapSpace: 16,
    this.gapSpaces,
    this.strokeColor: Colors.cyan,
    this.strokeWidth: 1,
    this.solidColor,
    this.enteredColor,
  }) : super(
          textStyle: textStyle,
          obscureStyle: obscureStyle,
          errorText: errorText,
          errorTextStyle: errorTextStyle,
          hintText: hintText,
          hintTextStyle: hintTextStyle,
        );

  @override
  PinDecoration copyWith({
    TextStyle textStyle,
    ObscureStyle obscureStyle,
    String errorText,
    TextStyle errorTextStyle,
    String hintText,
    TextStyle hintTextStyle,
  }) {
    return CirclePinDecoration(
      textStyle: textStyle ?? this.textStyle,
      obscureStyle: obscureStyle ?? this.obscureStyle,
      errorText: errorText ?? this.errorText,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      hintText: hintText ?? this.hintText,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      solidColor: this.solidColor,
      strokeColor: this.strokeColor,
      strokeWidth: this.strokeWidth,
      enteredColor: this.enteredColor,
      gapSpace: this.gapSpace,
      gapSpaces: this.gapSpaces,
    );
  }

  @override
  PinEntryType get pinEntryType => PinEntryType.customized;

  @override
  void drawPin(
    Canvas canvas,
    Size size,
    String text,
    pinLength,
    ThemeData themeData,
  ) {
    /// Calculate the height of paint area for drawing the pin field.
    /// it should honor the error text (if any) drawn by
    /// the actual texfield behind.
    /// but, since we can access the drawn textfield behind from here,
    /// we use a simple logic to calculate it.
    double mainHeight;
    if (errorText != null && errorText.isNotEmpty) {
      mainHeight = size.height - (errorTextStyle.fontSize + 8.0);
    } else {
      mainHeight = size.height;
    }

    Paint borderPaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    /// Assign paint if [solidColor] is not null
    Paint insidePaint;
    if (solidColor != null) {
      insidePaint = Paint()
        ..color = solidColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
    }

    double gapTotalLength = gapSpaces?.sumList() ?? (pinLength - 1) * gapSpace;

    /// Calculate the width of each digit include stroke.
    double singleWidth =
        (size.width - strokeWidth - gapTotalLength) / pinLength;

    double radius; // include strokeWidth
    List<double> actualGapSpaces;
    if (singleWidth / 2 < mainHeight / 2 - strokeWidth / 2) {
      radius = singleWidth / 2;
      actualGapSpaces = gapSpaces == null
          ? List.castFrom(gapSpaces)
          : List.filled(pinLength - 1, gapSpace);
    } else {
      radius = mainHeight / 2 - strokeWidth / 2;
      actualGapSpaces = List.filled(
          pinLength - 1,
          (size.width - strokeWidth - radius * 2 * pinLength) /
              (pinLength - 1));
    }

    double startX = strokeWidth / 2;
    double startY = mainHeight / 2;

    List<double> centerPoints = List(pinLength);

    /// Draw the each shape of pin.
    for (int i = 0; i < pinLength; i++) {
      if (i < text.length && enteredColor != null) {
        borderPaint.color = enteredColor;
      } else if (errorText != null && errorText.isNotEmpty) {
        /// only draw error-color as border-color or solid-color
        /// if errorText is not null
        if (solidColor == null) {
          borderPaint.color = errorTextStyle.color;
        } else {
          insidePaint = Paint()
            ..color = errorTextStyle.color
            ..style = PaintingStyle.fill
            ..isAntiAlias = true;
        }
      } else {
        borderPaint.color = strokeColor;
      }
      centerPoints[i] = startX + radius;
      canvas.drawCircle(
        Offset(centerPoints[i], startY),
        radius,
        borderPaint,
      );
      if (insidePaint != null) {
        canvas.drawCircle(
          Offset(startX + radius, startY),
          radius - strokeWidth / 2,
          insidePaint,
        );
      }
      startX += (radius * 2 + (i == pinLength - 1 ? 0 : actualGapSpaces[i]));
    }

    /// The char index of the [text]
    var index = 0;
    startY = 0.0;

    /// Determine whether display obscureText.
    bool obscureOn = obscureStyle?.isTextObscure == true;

    text.runes.forEach((rune) {
      String code;
      if (obscureOn) {
        code = obscureStyle.obscureText;
      } else {
        code = String.fromCharCode(rune);
      }
      TextPainter textPainter = TextPainter(
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
      textPainter.paint(
          canvas,
          Offset(
            centerPoints[index] - textPainter.width / 2,
            startY,
          ));
      index++;
    });

    if (hintText != null) {
      hintText.substring(index).runes.forEach((rune) {
        String code = String.fromCharCode(rune);
        TextPainter textPainter = TextPainter(
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
        textPainter.paint(canvas,
            Offset(centerPoints[index] - textPainter.width / 2, startY));
        index++;
      });
    }
  }

  @override
  double get getGapWidth => gapSpace;

  @override
  List<double> get getGapWidthList => gapSpaces;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is CirclePinDecoration &&
          runtimeType == other.runtimeType &&
          strokeWidth == other.strokeWidth &&
          gapSpace == other.gapSpace &&
          gapSpaces == other.gapSpaces &&
          strokeColor == other.strokeColor &&
          solidColor == other.solidColor &&
          enteredColor == other.enteredColor;

  @override
  int get hashCode =>
      super.hashCode ^
      strokeWidth.hashCode ^
      gapSpace.hashCode ^
      gapSpaces.hashCode ^
      strokeColor.hashCode ^
      solidColor.hashCode ^
      enteredColor.hashCode;

  @override
  String toString() {
    return 'CirclePinDecoration{strokeWidth: $strokeWidth, gapSpace: $gapSpace, gapSpaces: $gapSpaces, strokeColor: $strokeColor, solidColor: $solidColor, enteredColor: $enteredColor}';
  }
}
