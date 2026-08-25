import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

Future<void> pumpMaterialWidget(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(
    home: Material(
      child: child,
    ),
  ));
}

final decoration = UnderlineDecoration(colorBuilder: const FixedColorBuilder(Colors.white));

Future<int> findLastErrorBorderPixel(
  WidgetTester tester,
  BoxLooseDecoration decoration,
) async {
  final boundaryKey = GlobalKey();

  await pumpMaterialWidget(
    tester,
    Center(
      child: RepaintBoundary(
        key: boundaryKey,
        child: SizedBox(
          width: 400,
          height: 74,
          child: PinInputTextFormField(
            initialValue: '1',
            pinLength: 4,
            autovalidateMode: AutovalidateMode.always,
            decoration: decoration,
            validator: (value) =>
                (value?.length ?? 0) < 4 ? 'OTP is required' : null,
          ),
        ),
      ),
    ),
  );
  await tester.pump();

  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await tester.runAsync(
    () => boundary.toImage(pixelRatio: 1),
  );
  final byteData = await tester.runAsync(
    () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
  );
  final pixels = byteData!.buffer.asUint8List();

  // Sample through the fourth box, away from the error label beneath the
  // first box. The last red pixel is the painted bottom border.
  const sampleX = 356;
  var lastRedPixelY = -1;
  for (var y = 0; y < image!.height; y++) {
    final offset = (y * image.width + sampleX) * 4;
    if (pixels[offset] > 200 &&
        pixels[offset + 1] < 100 &&
        pixels[offset + 2] < 100 &&
        pixels[offset + 3] > 0) {
      lastRedPixelY = y;
    }
  }
  image.dispose();

  return lastRedPixelY;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create Text Field', (WidgetTester tester) async {
    await pumpMaterialWidget(tester, PinInputTextField(decoration: decoration,));
  });

  testWidgets('Get pin text', (WidgetTester tester) async {
    var controller = TextEditingController();
    await pumpMaterialWidget(
        tester,
        PinInputTextField(
          controller: controller,
          decoration: UnderlineDecoration(
              colorBuilder: const FixedColorBuilder(Colors.cyan)),
        ));
    await tester.enterText(find.byType(TextField), '1234');
    expect('1234', controller.text);
  });

  testWidgets('Detect keyboard', (WidgetTester tester) async {
    FocusNode focusNode = FocusNode();
    GlobalKey key = GlobalKey();

    await pumpMaterialWidget(
        tester,
        Column(
          children: <Widget>[
            PinInputTextField(
              key: key,
              controller: TextEditingController(text: '123'),
              focusNode: focusNode,
              autoFocus: true,
              decoration: decoration,
            ),
            const TextField(),
          ],
        ));

    expect(focusNode.hasFocus, true);

    focusNode.nextFocus();

    await pumpMaterialWidget(
        tester,
        Column(
          children: <Widget>[
            PinInputTextField(
              key: key,
              controller: TextEditingController(text: '123'),
              focusNode: focusNode,
              decoration: decoration,
            ),
            const TextField(),
          ],
        ));
    expect(focusNode.hasFocus, false);
    await tester.tap(find.byKey(key));
    expect(focusNode.hasFocus, true);
  });

  test('Built-in decorations preserve custom validator error spacing', () {
    final decorations = <PinDecoration>[
      UnderlineDecoration(
        errorTextSpacing: 12,
        colorBuilder: const FixedColorBuilder(Colors.black),
      ),
      BoxLooseDecoration(
        errorTextSpacing: 12,
        strokeColorBuilder: const FixedColorBuilder(Colors.black),
      ),
      BoxTightDecoration(errorTextSpacing: 12),
      CirclePinDecoration(
        errorTextSpacing: 12,
        strokeColorBuilder: const FixedColorBuilder(Colors.black),
      ),
    ];

    for (final decoration in decorations) {
      expect(decoration.errorTextSpacing, 12);
      expect(
        decoration.copyWith(errorText: 'OTP is required').errorTextSpacing,
        12,
      );
    }
  });

  testWidgets('Validator error spacing is configurable',
      (WidgetTester tester) async {
    final defaultDecoration = BoxLooseDecoration(
      errorTextStyle: const TextStyle(color: Colors.red, fontSize: 12),
      strokeColorBuilder: const FixedColorBuilder(Colors.black),
    );
    expect(
      defaultDecoration.errorTextSpacing,
      PinDecoration.defaultErrorTextSpacing,
    );
    final defaultBorderY = await findLastErrorBorderPixel(
      tester,
      defaultDecoration,
    );
    expect(defaultBorderY, lessThanOrEqualTo(54));

    final customDecoration = BoxLooseDecoration(
      errorTextStyle: const TextStyle(color: Colors.red, fontSize: 12),
      errorTextSpacing: 20,
      strokeColorBuilder: const FixedColorBuilder(Colors.black),
    );
    final copiedDecoration =
        customDecoration.copyWith(errorText: 'OTP is required');
    expect(copiedDecoration.errorTextSpacing, 20);
    final customBorderY = await findLastErrorBorderPixel(
      tester,
      customDecoration,
    );
    expect(customBorderY, lessThan(defaultBorderY));
  });
}
