import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension NumListExtension<T extends num> on Iterable<T> {
  /// Return the sum of the list even the list is empty.
  T sumList() {
    if (T == int) {
      var sum = 0;
      this.forEach((n) => sum += n);
      return sum as T;
    } else if (T == double) {
      var sum = 0.0;
      this.forEach((n) => sum += n);
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
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android Platform is not allowed 0 font size when selectAll
      return double.minPositive;
    }
    return 0;
  } catch (_) {
    return 1;
  }
}
