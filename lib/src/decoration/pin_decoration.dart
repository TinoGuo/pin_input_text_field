import 'package:flutter/material.dart';

import '../style/obscure.dart';
import '../util/utils.dart';

part 'decoration_boxloose.dart';
part 'decoration_boxtight.dart';
part 'decoration_circle.dart';
part 'decoration_underline.dart';

enum PinEntryType {
  underline,
  boxTight,
  boxLoose,
  circle,
  customized,
}

class SupportGap {
  /// The adjacent box gap.
  double get getGapWidth => 0;

  /// The gaps between every two adjacent box, higher priority than [gapSpace].
  List<double> get getGapWidthList => Iterable.empty();
}

abstract class PinDecoration {
  /// The style of painting text.
  final TextStyle textStyle;

  /// The style of obscure text.
  final ObscureStyle obscureStyle;

  /// The error text that will be displayed if any
  final String errorText;

  /// The style of error text.
  final TextStyle errorTextStyle;

  final String hintText;

  final TextStyle hintTextStyle;

  PinEntryType get pinEntryType;

  const PinDecoration({
    this.textStyle,
    this.obscureStyle,
    this.errorText,
    this.errorTextStyle,
    this.hintText,
    this.hintTextStyle,
  });

  void drawPin(
    Canvas canvas,
    Size size,
    String text,
    pinLength,
    ThemeData themeData,
  );

  /// Creates a copy of this pin decoration with the given fields replaced
  /// by the new values.
  PinDecoration copyWith({
    TextStyle textStyle,
    ObscureStyle obscureStyle,
    String errorText,
    TextStyle errorTextStyle,
    String hintText,
    TextStyle hintTextStyle,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PinDecoration &&
          runtimeType == other.runtimeType &&
          textStyle == other.textStyle &&
          obscureStyle == other.obscureStyle &&
          errorText == other.errorText &&
          errorTextStyle == other.errorTextStyle &&
          hintText == other.hintText &&
          hintTextStyle == other.hintTextStyle;

  @override
  int get hashCode =>
      textStyle.hashCode ^
      obscureStyle.hashCode ^
      errorText.hashCode ^
      errorTextStyle.hashCode ^
      hintText.hashCode ^
      hintTextStyle.hashCode;

  @override
  String toString() {
    return 'PinDecoration{textStyle: $textStyle, obscureStyle: $obscureStyle, errorText: $errorText, errorTextStyle: $errorTextStyle, hintText: $hintText, hintTextStyle: $hintTextStyle}';
  }
}
