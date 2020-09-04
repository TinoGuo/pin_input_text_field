import 'dart:ui';

/// This class is abstract for query index of color.
abstract class ColorBuilder {
  const ColorBuilder();

  // query the index of color
  Color indexColor(int index);

  void notifyChange(String enteredPin) {}
}

// Provide fixed color list to query, it would throw [RangeError] if index out of bound.
class FixedColorListBuilder extends ColorBuilder {
  final List<Color> colorList;

  const FixedColorListBuilder(this.colorList);

  @override
  Color indexColor(int index) => colorList[index];
}

// Provide fixed color for all index.
class FixedColorBuilder extends ColorBuilder {
  final Color color;

  const FixedColorBuilder(this.color);

  @override
  Color indexColor(int index) => color;
}

// Provide the basic way to differ entered color and not entered color.
class EnteredColorBuilder extends ColorBuilder {
  final Color enteredColor;
  final Color notEnteredColor;
  var maxIndex = 0;

  EnteredColorBuilder(this.enteredColor, this.notEnteredColor);

  @override
  Color indexColor(int index) {
    return index >= maxIndex ? notEnteredColor : enteredColor;
  }

  @override
  void notifyChange(String enteredPin) {
    maxIndex = enteredPin.length;
  }
}
