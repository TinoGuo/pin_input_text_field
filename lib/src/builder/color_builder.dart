import 'dart:ui';

import 'package:pin_input_text_field/src/builder/property_builder.dart';

/// This class is abstract for query index of color.
abstract class ColorBuilder extends PropertyIndexBuilder<Color> {
  const ColorBuilder();
}

// Provide fixed color list to query, it would throw [RangeError] if index out of bound.
class FixedColorListBuilder extends ColorBuilder {
  final List<Color> colorList;

  const FixedColorListBuilder(this.colorList);

  @override
  Color indexProperty(int index) => colorList[index];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedColorListBuilder &&
          runtimeType == other.runtimeType &&
          colorList == other.colorList;

  @override
  int get hashCode => colorList.hashCode;
}

// Provide fixed color for all index.
class FixedColorBuilder extends ColorBuilder {
  final Color color;

  const FixedColorBuilder(this.color);

  @override
  Color indexProperty(int index) => color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedColorBuilder &&
          runtimeType == other.runtimeType &&
          color == other.color;

  @override
  int get hashCode => color.hashCode;
}

// Provide the basic way to differ entered color and not entered color.
class PinListenColorBuilder extends ColorBuilder {
  final Color enteredColor;
  final Color notEnteredColor;
  var maxIndex = 0;

  PinListenColorBuilder(this.enteredColor, this.notEnteredColor);

  @override
  Color indexProperty(int index) {
    return index >= maxIndex ? notEnteredColor : enteredColor;
  }

  @override
  void notifyChange(String enteredPin) {
    maxIndex = enteredPin.length;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PinListenColorBuilder &&
          runtimeType == other.runtimeType &&
          enteredColor == other.enteredColor &&
          notEnteredColor == other.notEnteredColor &&
          maxIndex == other.maxIndex;

  @override
  int get hashCode =>
      enteredColor.hashCode ^ notEnteredColor.hashCode ^ maxIndex.hashCode;
}
