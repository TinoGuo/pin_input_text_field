// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:pin_input_text_field/src/util/utils.dart';

part '_pin_state.dart';

const _kDefaultPinLength = 6;

class PinInputTextField extends StatefulWidget {
  /// The max length of pin.
  final int pinLength;

  /// The callback will execute when user click done.
  final ValueChanged<String>? onSubmit;

  /// Decorate the pin.
  final PinDecoration decoration;

  /// Just like [TextField]'s inputFormatter.
  final List<TextInputFormatter>? inputFormatters;

  /// Just like [TextField]'s keyboardType.
  final TextInputType keyboardType;

  /// Controls the pin being edited.
  final TextEditingController? controller;

  /// Same as [TextField]'s autoFocus.
  final bool autoFocus;

  /// Same as [TextField]'s focusNode.
  final FocusNode? focusNode;

  /// Same as [TextField]'s textInputAction.
  final TextInputAction textInputAction;

  /// Same as [TextField]'s enabled.
  final bool enabled;

  /// Same as [TextField]'s onChanged.
  final ValueChanged<String>? onChanged;

  /// Same as [TextField]'s textCapitalization
  final TextCapitalization textCapitalization;

  /// Same as [TextField]'s autocorrect
  final bool autocorrect;

  /// Same as [TextField]'s enableInteractiveSelection
  final bool enableInteractiveSelection;

  /// Same as [TextField]'s toolbarOptions
  @Deprecated(
    'Use `contextMenuBuilder` instead. '
        'This feature was deprecated after flutter v3.3.0-0.5.pre.',
  )
  final ToolbarOptions? toolbarOptions;

  /// Same as [TextField]'s contextMenuBuilder
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// Same as [TextField]'s autofillHints
  final Iterable<String>? autofillHints;

  /// The cursor of the pin widget, the default is disabled.
  final Cursor cursor;

  final TapRegionCallback? tapRegionCallback;

  PinInputTextField({
    Key? key,
    this.pinLength = _kDefaultPinLength,
    this.onSubmit,
    required this.decoration,
    this.inputFormatters,
    this.keyboardType = TextInputType.phone,
    this.controller,
    this.focusNode,
    this.autoFocus = false,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.onChanged,
    textCapitalization,
    this.autocorrect = false,
    this.enableInteractiveSelection = false,
    this.toolbarOptions,
    this.contextMenuBuilder,
    this.autofillHints,
    Cursor? cursor,
    this.tapRegionCallback,
  })  :

        /// pinLength must larger than 0.
        /// If pinEditingController isn't null, guarantee the [pinLength] equals to the pinEditingController's _pinMaxLength
        assert(pinLength > 0),

        /// Hint length must equal to the [pinLength].
        assert(decoration.hintText == null ||
            decoration.hintText!.length == pinLength),
        assert(decoration is! SupportGap ||
            (decoration is SupportGap &&
                    (decoration as SupportGap).getGapWidthList == null ||
                (decoration as SupportGap).getGapWidthList!.length ==
                    pinLength - 1)),
        textCapitalization = textCapitalization ?? TextCapitalization.none,
        cursor = cursor ?? Cursor.disabled(),
        super(key: key);

  @override
  State createState() {
    return _PinInputTextFieldState();
  }
}

class PinInputTextFormField extends FormField<String> {
  /// Controls the pin being edited.
  final TextEditingController? controller;

  /// The max length of pin.
  final int pinLength;

  PinInputTextFormField({
    Key? key,
    this.controller,
    String? initialValue,
    this.pinLength = _kDefaultPinLength,
    ValueChanged<String>? onSubmit,
    required PinDecoration decoration,
    List<TextInputFormatter>? inputFormatters,
    TextInputType keyboardType = TextInputType.phone,
    FocusNode? focusNode,
    bool autoFocus = false,
    TextInputAction textInputAction = TextInputAction.done,
    bool enabled = true,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    ValueChanged<String>? onChanged,
    TextCapitalization? textCapitalization,
    bool autocorrect = false,
    bool enableInteractiveSelection = false,
    ToolbarOptions? toolbarOptions,
    EditableTextContextMenuBuilder? contextMenuBuilder,
    Iterable<String>? autofillHints,
    Cursor? cursor,
    TapRegionCallback? tapRegionCallback,
  })  : assert(initialValue == null || controller == null),
        super(
            key: key,
            initialValue:
                controller != null ? controller.text : (initialValue ?? ''),
            onSaved: onSaved,
            validator: validator,
            autovalidateMode: autovalidateMode,
            enabled: enabled,
            builder: (FormFieldState<String> field) {
              return PinInputTextField(
                pinLength: pinLength,
                onSubmit: onSubmit,
                decoration: decoration.copyWith(errorText: field.errorText),
                inputFormatters: inputFormatters,
                keyboardType: keyboardType,
                controller:
                    (field as _PinInputTextFormFieldState)._effectiveController,
                focusNode: focusNode,
                autoFocus: autoFocus,
                textInputAction: textInputAction,
                enabled: enabled,
                onChanged: onChanged,
                textCapitalization: textCapitalization,
                enableInteractiveSelection: enableInteractiveSelection,
                autocorrect: autocorrect,
                toolbarOptions: toolbarOptions,
                contextMenuBuilder: contextMenuBuilder,
                autofillHints: autofillHints,
                cursor: cursor,
                tapRegionCallback: tapRegionCallback,
              );
            });

  @override
  FormFieldState<String> createState() => _PinInputTextFormFieldState();
}
