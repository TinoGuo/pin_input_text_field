// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

final _decoration = UnderlineDecoration(
  colorBuilder: const FixedColorBuilder(Colors.white),
);

Future<void> _pumpMaterialWidget(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(home: Material(child: child)));
}

Widget _contextMenuBuilder(
  BuildContext context,
  EditableTextState editableTextState,
) =>
    const SizedBox.shrink();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PinInputTextField forwards toolbar and context menu options', (
    WidgetTester tester,
  ) async {
    const toolbarOptions = ToolbarOptions(
      copy: true,
      cut: true,
      paste: false,
      selectAll: false,
    );
    await _pumpMaterialWidget(
      tester,
      PinInputTextField(
        decoration: _decoration,
        toolbarOptions: toolbarOptions,
        contextMenuBuilder: _contextMenuBuilder,
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.toolbarOptions, same(toolbarOptions));
    expect(textField.contextMenuBuilder, same(_contextMenuBuilder));
  });

  testWidgets('PinInputTextFormField forwards toolbar options', (
    WidgetTester tester,
  ) async {
    const toolbarOptions = ToolbarOptions(
      copy: false,
      cut: false,
      paste: true,
      selectAll: true,
    );

    await _pumpMaterialWidget(
      tester,
      PinInputTextFormField(
        decoration: _decoration,
        toolbarOptions: toolbarOptions,
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.toolbarOptions, same(toolbarOptions));
  });

  testWidgets('toolbar options remain null when omitted', (
    WidgetTester tester,
  ) async {
    await _pumpMaterialWidget(
      tester,
      PinInputTextField(decoration: _decoration),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.toolbarOptions, isNull);
  });
}
