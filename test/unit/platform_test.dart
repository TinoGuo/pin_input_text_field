import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_input_text_field/src/util/utils.dart';

void main() {
  group('check all platform mini size', () {
    testWidgets('check android', (tester) async {
      var fontSize = platformMiniFontSize();
      expect(double.minPositive, fontSize);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets('check web', (tester) async {
      overrideDebugWebValue = true;
      var fontSize = platformMiniFontSize();
      expect(1, fontSize);
      overrideDebugWebValue = false;
    });

    final Set<TargetPlatform> exceptAndroidSet = TargetPlatform.values.toSet();
    exceptAndroidSet.remove(TargetPlatform.android);
    testWidgets('check other platform', (tester) async {
      var fontSize = platformMiniFontSize();
      expect(0, fontSize);
    }, variant: TargetPlatformVariant(exceptAndroidSet));
  });
}
