part of 'pin_decoration.dart';

/// The object determine the underline color etc.
class UnderlineDecoration extends PinDecoration implements SupportGap {
  /// The space between text and underline.
  final double gapSpace;

  /// The gaps between every two adjacent box, higher priority than [gapSpace].
  final List<double> gapSpaces;

  /// The color of the underline.
  final Color color;

  /// The height of the underline.
  final double lineHeight;

  /// The underline changed color when user enter pin.
  final Color enteredColor;

  const UnderlineDecoration({
    TextStyle textStyle,
    ObscureStyle obscureStyle,
    String errorText,
    TextStyle errorTextStyle,
    String hintText,
    TextStyle hintTextStyle,
    this.enteredColor,
    this.gapSpace: 16.0,
    this.gapSpaces,
    this.color: Colors.cyan,
    this.lineHeight: 2.0,
  }) : super(
          textStyle: textStyle,
          obscureStyle: obscureStyle,
          errorText: errorText,
          errorTextStyle: errorTextStyle,
          hintText: hintText,
          hintTextStyle: hintTextStyle,
        );

  @override
  PinEntryType get pinEntryType => PinEntryType.underline;

  @override
  PinDecoration copyWith({
    TextStyle textStyle,
    ObscureStyle obscureStyle,
    String errorText,
    TextStyle errorTextStyle,
    String hintText,
    TextStyle hintTextStyle,
  }) {
    return UnderlineDecoration(
      textStyle: textStyle ?? this.textStyle,
      obscureStyle: obscureStyle ?? this.obscureStyle,
      errorText: errorText ?? this.errorText,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      hintText: hintText ?? this.hintText,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      enteredColor: this.enteredColor,
      color: this.color,
      gapSpace: this.gapSpace,
      lineHeight: this.lineHeight,
      gapSpaces: this.gapSpaces,
    );
  }

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

    Paint underlinePaint = Paint()
      ..color = color
      ..strokeWidth = lineHeight
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    var startX = 0.0;
    var startY = mainHeight - lineHeight;

    double gapTotalLength =
        gapSpaces?.reduce((a, b) => a + b) ?? (pinLength - 1) * gapSpace;

    List<double> actualGapSpaces =
        gapSpaces ?? List.filled(pinLength - 1, gapSpace);

    /// Calculate the width of each underline.
    double singleWidth = (size.width - gapTotalLength) / pinLength;

    for (int i = 0; i < pinLength; i++) {
      if (i < text.length && enteredColor != null) {
        underlinePaint.color = enteredColor;
      } else if (errorText != null && errorText.isNotEmpty) {
        /// only draw error-color as underline-color if errorText is not null
        underlinePaint.color = errorTextStyle.color;
      } else {
        underlinePaint.color = color;
      }
      canvas.drawLine(Offset(startX, startY),
          Offset(startX + singleWidth, startY), underlinePaint);
      startX += singleWidth + (i == pinLength - 1 ? 0 : actualGapSpaces[i]);
    }

    /// The char index of the [text]
    var index = 0;
    startX = 0.0;
    startY = 0.0;

    /// Determine whether display obscureText.
    bool obscureOn = obscureStyle != null && obscureStyle.isTextObscure;

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
      startX = singleWidth * index +
          singleWidth / 2 -
          textPainter.width / 2 +
          actualGapSpaces.take(index).sumList();
      textPainter.paint(canvas, Offset(startX, startY));
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
  List<double> get getGapWidthList => gapSpaces;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is UnderlineDecoration &&
          runtimeType == other.runtimeType &&
          gapSpace == other.gapSpace &&
          gapSpaces == other.gapSpaces &&
          color == other.color &&
          lineHeight == other.lineHeight &&
          enteredColor == other.enteredColor;

  @override
  int get hashCode =>
      super.hashCode ^
      gapSpace.hashCode ^
      gapSpaces.hashCode ^
      color.hashCode ^
      lineHeight.hashCode ^
      enteredColor.hashCode;

  @override
  String toString() {
    return 'UnderlineDecoration{gapSpace: $gapSpace, gapSpaces: $gapSpaces, color: $color, lineHeight: $lineHeight, enteredColor: $enteredColor}';
  }
}
