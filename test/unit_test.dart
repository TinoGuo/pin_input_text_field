import 'package:flutter_test/flutter_test.dart';

void main() {
  group('String rune', () {
    test('subString from runes', () {
      String s = 'foo';
      String newS = String.fromCharCodes(s.runes.take(2));
      expect(newS, 'fo');

      s = '123';
      newS = String.fromCharCodes(s.runes.take(2));
      expect(newS, '12');

      s = '你好啊';
      newS = String.fromCharCodes(s.runes.take(2));
      expect(newS, '你好');
    });
  });
}
