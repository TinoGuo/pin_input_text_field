import 'package:flutter/material.dart';
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
}
