import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../decoration/pin_decoration.dart';

const _kDefaultPinLength = 6;

class PinInputTextField extends StatefulWidget {
  /// The max length of pin.
  final int pinLength;

  /// The callback will execute when user click done.
  final ValueChanged<String> onSubmit;

  /// Decorate the pin.
  final PinDecoration decoration;

  /// Just like [TextField]'s inputFormatter.
  final List<TextInputFormatter> inputFormatters;

  /// Just like [TextField]'s keyboardType.
  final TextInputType keyboardType;

  /// Controls the pin being edited.
  final TextEditingController controller;

  /// Same as [TextField]'s autoFocus.
  final bool autoFocus;

  /// Same as [TextField]'s focusNode.
  final FocusNode focusNode;

  /// Same as [TextField]'s textInputAction.
  final TextInputAction textInputAction;

  /// Same as [TextField]'s enabled.
  final bool enabled;

  /// Same as [TextField]'s onChanged.
  final ValueChanged<String> onChanged;

  PinInputTextField({
    Key key,
    this.pinLength: _kDefaultPinLength,
    this.onSubmit,
    this.decoration: const BoxLooseDecoration(),
    List<TextInputFormatter> inputFormatter,
    this.keyboardType: TextInputType.phone,
    this.controller,
    this.focusNode,
    this.autoFocus = false,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.onChanged,
  })  :

        /// pinLength must larger than 0.
        /// If pinEditingController isn't null, guarantee the [pinLength] equals to the pinEditingController's _pinMaxLength
        assert(pinLength != null && pinLength > 0),
        assert(decoration != null),

        /// Hint length must equal to the [pinLength].
        assert(decoration.hintText == null ||
            decoration.hintText.length == pinLength),
        assert(!(decoration is SupportGap) ||
            (decoration is SupportGap &&
                    (decoration as SupportGap).getGapWidthList == null ||
                (decoration as SupportGap).getGapWidthList.length ==
                    pinLength - 1)),
        inputFormatters = inputFormatter == null
            ? <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(pinLength),
              ]
            : inputFormatter
          ..add(LengthLimitingTextInputFormatter(pinLength)),
        super(key: key);

  @override
  State createState() {
    return _PinInputTextFieldState();
  }
}

class _PinInputTextFieldState extends State<PinInputTextField> {
  /// The display text to the user.
  String _text;

  TextEditingController _controller;

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller;

  void _pinChanged() {
    setState(() {
      _updateText();

      /// This below code will cause dead loop in iOS,
      /// you should assign selection when you set text.
//      _effectiveController.selection = TextSelection.collapsed(
//          offset: _effectiveController.text.runes.length);
    });
  }

  void _updateText() {
    if (_effectiveController.text.runes.length > widget.pinLength) {
      _text = String.fromCharCodes(
          _effectiveController.text.runes.take(widget.pinLength));
    } else {
      _text = _effectiveController.text;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
    }
    _effectiveController.addListener(_pinChanged);

    //Ensure the initial value will be displayed when the field didn't get the focus.
    _updateText();
  }

  @override
  void dispose() {
    // Ensure no listener will execute after dispose.
    _effectiveController.removeListener(_pinChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(PinInputTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null && oldWidget.controller != null) {
      oldWidget.controller.removeListener(_pinChanged);
      _controller = TextEditingController.fromValue(oldWidget.controller.value);
      _controller.addListener(_pinChanged);
    } else if (widget.controller != null && oldWidget.controller == null) {
      _controller.removeListener(_pinChanged);
      _controller = null;
      widget.controller.addListener(_pinChanged);
      // Invalidate the text when controller hold different old text.
      if (_text != widget.controller.text) {
        _pinChanged();
      }
    } else if (widget.controller != oldWidget.controller) {
      // The old controller and current controller is not null and not the same.
      oldWidget.controller.removeListener(_pinChanged);
      widget.controller.addListener(_pinChanged);
    }

    /// If the newLength is shorter than now and the current text length longer
    /// than [pinLength], So we should cut the superfluous subString.
    if (oldWidget.pinLength > widget.pinLength &&
        _text.runes.length > widget.pinLength) {
      setState(() {
        _text = _text.substring(0, widget.pinLength);
        _effectiveController.text = _text;
        _effectiveController.selection =
            TextSelection.collapsed(offset: _text.runes.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      /// The foreground paint to display pin.
      foregroundPainter: _PinPaint(
        text: _text ?? _text.trim(),
        pinLength: widget.pinLength,
        decoration: widget.decoration,
        themeData: Theme.of(context),
      ),
      child: TextField(
        /// Actual textEditingController.
        controller: _effectiveController,

        /// Fake the text style.
        style: TextStyle(
          /// Hide the editing text.
          color: Colors.transparent,
          fontSize: 1,
        ),

        /// Hide the Cursor.
        cursorColor: Colors.transparent,

        /// Hide the cursor.
        cursorWidth: 0.0,

        /// No need to correct the user input.
        autocorrect: false,

        /// Center the input to make more natural.
        textAlign: TextAlign.center,

        /// Disable the actual textField selection.
        enableInteractiveSelection: false,

        /// The maxLength of the pin input, the default value is 6.
        maxLength: widget.pinLength,

        /// If use system keyboard and user click done, it will execute callback
        /// Note!!! Custom keyboard in Android will not execute, see the related issue [https://github.com/flutter/flutter/issues/19027]
        onSubmitted: widget.onSubmit,

        /// Default text input type is number.
        keyboardType: widget.keyboardType,

        /// only accept digits.
        inputFormatters: widget.inputFormatters,

        /// Defines the keyboard focus for this widget.
        focusNode: widget.focusNode,

        /// {@macro flutter.widgets.editableText.autofocus}
        autofocus: widget.autoFocus,

        /// The type of action button to use for the keyboard.
        ///
        /// Defaults to [TextInputAction.done]
        textInputAction: widget.textInputAction,

        /// {@macro flutter.widgets.editableText.obscureText}
        /// Default value of the obscureText is false. Make
        obscureText: true,

        onChanged: widget.onChanged,

        enabled: widget.enabled,

        /// Clear default text decoration.
        decoration: InputDecoration(
          /// Hide the counterText
          counterText: '',

          /// Hide the outline border.
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),

          /// Bind the error text from pin decoration to this input decoration.
          errorText: widget.decoration.errorText,

          /// Bind the style of error text from pin decoration to
          /// this input decoration.
          errorStyle: widget.decoration.errorTextStyle,
        ),
      ),
    );
  }
}

class _PinPaint extends CustomPainter {
  final String text;
  final int pinLength;
  final PinEntryType type;
  final PinDecoration decoration;
  final ThemeData themeData;

  _PinPaint({
    @required this.text,
    @required this.pinLength,
    PinDecoration decoration,
    this.type: PinEntryType.boxTight,
    this.themeData,
  }) : this.decoration = decoration.copyWith(
          textStyle: decoration.textStyle ?? themeData.textTheme.headline5,
          errorTextStyle: decoration.errorTextStyle ??
              themeData.textTheme.caption.copyWith(color: themeData.errorColor),
          hintTextStyle: decoration.hintTextStyle ??
              themeData.textTheme.headline5
                  .copyWith(color: themeData.hintColor),
        );

  @override
  bool shouldRepaint(CustomPainter oldDelegate) =>
      !(oldDelegate is _PinPaint && oldDelegate.text == this.text);

  @override
  void paint(Canvas canvas, Size size) {
    decoration.drawPin(canvas, size, text, pinLength, themeData);
  }
}

class PinInputTextFormField extends FormField<String> {
  /// Controls the pin being edited.
  final TextEditingController controller;

  /// The max length of pin.
  final int pinLength;

  /// Just like [TextField]'s inputFormatter.
  final List<TextInputFormatter> inputFormatters;

  PinInputTextFormField({
    Key key,
    this.controller,
    String initialValue,
    this.pinLength = _kDefaultPinLength,
    ValueChanged<String> onSubmit,
    PinDecoration decoration = const BoxLooseDecoration(),
    List<TextInputFormatter> inputFormatter,
    TextInputType keyboardType = TextInputType.phone,
    FocusNode focusNode,
    bool autoFocus = false,
    TextInputAction textInputAction = TextInputAction.done,
    bool enabled = true,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
    bool autovalidate = false,
    ValueChanged<String> onChanged,
  })  : assert(initialValue == null || controller == null),
        assert(autovalidate != null),
        assert(pinLength != null && pinLength > 0),

        /// pinLength must larger than 0.
        /// If pinEditingController isn't null, guarantee the [pinLength] equals to the pinEditingController's _pinMaxLength
        assert(pinLength != null && pinLength > 0),
        assert(decoration != null),

        /// Hint length must equal to the [pinLength].
        assert(decoration.hintText == null ||
            decoration.hintText.length == pinLength),
        assert(!(decoration is SupportGap) ||
            (decoration is SupportGap &&
                    (decoration as SupportGap).getGapWidthList == null ||
                (decoration as SupportGap).getGapWidthList.length ==
                    pinLength - 1)),
        inputFormatters = inputFormatter == null
            ? <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(pinLength),
              ]
            : inputFormatter
          ..add(LengthLimitingTextInputFormatter(pinLength)),
        super(
            key: key,
            initialValue:
                controller != null ? controller.text : (initialValue ?? ''),
            onSaved: onSaved,
            validator: (value) {
              var result = validator(value);
              if (result == null) {
                if (value.isEmpty) {
                  return 'Input field is empty.';
                }
                if (value.length < pinLength) {
                  if (pinLength - value.length > 1) {
                    return 'Missing ${pinLength - value.length} digits of input.';
                  } else {
                    return 'Missing last digit of input.';
                  }
                }
              }
              return result;
            },
            autovalidate: autovalidate,
            enabled: enabled,
            builder: (FormFieldState<String> field) {
              final _PinInputTextFormFieldState state = field;
              return PinInputTextField(
                pinLength: pinLength,
                onSubmit: onSubmit,
                decoration: decoration.copyWith(errorText: field.errorText),
                inputFormatter: inputFormatter,
                keyboardType: keyboardType,
                controller: state._effectiveController,
                focusNode: focusNode,
                autoFocus: autoFocus,
                textInputAction: textInputAction,
                enabled: enabled,
                onChanged: onChanged,
              );
            });

  @override
  _PinInputTextFormFieldState createState() => _PinInputTextFormFieldState();
}

class _PinInputTextFormFieldState extends FormFieldState<String> {
  TextEditingController _controller;

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller;

  @override
  PinInputTextFormField get widget => super.widget;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    }
    _effectiveController.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(PinInputTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null && oldWidget.controller != null) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      _controller = TextEditingController.fromValue(oldWidget.controller.value);
      _controller.addListener(_handleControllerChanged);
    } else if (widget.controller != null && oldWidget.controller == null) {
      _controller.removeListener(_handleControllerChanged);
      _controller = null;
      widget.controller.addListener(_handleControllerChanged);
      // Invalidate the text when controller hold different old text.
      if (value != widget.controller.text) {
        _handleControllerChanged();
      }
    } else if (widget.controller != oldWidget.controller) {
      // The old controller and current controller is not null and not the same.
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
    }

    /// If the newLength is shorter than now and the current text length longer
    /// than [pinLength], So we should cut the superfluous subString.
    if (oldWidget.pinLength > widget.pinLength &&
        value.runes.length > widget.pinLength) {
      setState(() {
        setValue(value.substring(0, widget.pinLength));
        _effectiveController.text = value;
        _effectiveController.selection = TextSelection.collapsed(
          offset: value.runes.length,
        );
      });
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController.text = widget.initialValue;
    });
  }

  @override
  void didChange(String value) {
    if (value.runes.length > widget.pinLength) {
      super.didChange(String.fromCharCodes(
        value.runes.take(widget.pinLength),
      ));
    } else {
      super.didChange(value);
    }
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController.text != value)
      didChange(_effectiveController.text);
  }
}
