import 'package:flutter_test/flutter_test.dart';
import 'package:pin_input_text_field/src/util/utils.dart';

void main() {
  group('check all platform mini size', () {
    testWidgets('check all platform', (tester) async {
      var fontSize = platformMiniFontSize();
      expect(double.minPositive, fontSize);
    }, variant: TargetPlatformVariant.all());

    testWidgets('check web', (tester) async {
      overrideDebugWebValue = true;
      var fontSize = platformMiniFontSize();
      expect(1, fontSize);
      overrideDebugWebValue = false;
    });
  });
}
