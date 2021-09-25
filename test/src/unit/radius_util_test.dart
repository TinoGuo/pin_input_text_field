import 'dart:ui';

import 'package:pin_input_text_field/src/util/radius_util.dart';
import 'package:test/test.dart';

void main() {
  group('get inner radius', () {
    test('outer radius larger than stroke', () {
      var radius = getInnerRadius(const Radius.circular(10.0), 10.0);
      expect(const Radius.circular(5.0), radius);
    });

    test('outer radius less than stroke', () {
      var radius = getInnerRadius(const Radius.circular(4.0), 10.0);
      expect(Radius.zero, radius);
    });
  });
}
