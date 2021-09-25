import 'package:flutter/foundation.dart';

extension NumListExtension<T extends num> on Iterable<T> {
  /// Return the sum of the list even the list is empty.
  T sumList() {
    if (T == int) {
      var sum = 0;
      forEach((n) => sum += n as int);
      return sum as T;
    } else if (T == double) {
      var sum = 0.0;
      forEach((n) => sum += n);
      return sum as T;
    }
    throw AssertionError("not support type:${T.runtimeType}");
  }
}

bool overrideDebugWebValue = false;

bool isWeb() => overrideDebugWebValue || kIsWeb;

double platformMiniFontSize() {
  try {
    if (isWeb()) {
      return 1; // Web is not allowed font size less than 1
    }
    return double.minPositive;
  } catch (_) {
    return 1;
  }
}
