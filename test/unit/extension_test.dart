import 'package:flutter_test/flutter_test.dart';
import 'package:pin_input_text_field/src/util/utils.dart';

void main() {
  group('num extension', () {
    test('num extension ', () {
      var list = [1, 2, 3];
      expect(6, list.sumList());

      list = [];
      expect(0, list.sumList());

      var doubleList = [1.0, 2.0];
      expect(3.0, doubleList.sumList());

      doubleList = [];
      expect(0.0, doubleList.sumList());
    });
  });
}
