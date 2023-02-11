part of 'pin_widget.dart';

class _PinInputTextFieldState extends State<PinInputTextField>
    with SingleTickerProviderStateMixin {
  /// The display text to the user.
  String _text = "";

  TextEditingController? _controller;

  late AnimationController _cursorBlinkOpacityController;
  final ValueNotifier<bool> _cursorVisibilityNotifier =
  ValueNotifier<bool>(true);
  Timer? _cursorTimer;
  bool _targetCursorVisibility = false;

  /// The current cursor color, the default one should be transparent if the TextField does not have focus.
  Color _cursorColor = Colors.transparent;

  TextEditingController? get _effectiveController =>
      widget.controller ?? _controller;

  void _pinChanged() {
    setState(() => _updateText());
  }

  FocusNode? _focusNode;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());

  void _updateText() {
    if (_effectiveController!.text.runes.length > widget.pinLength) {
      _text = String.fromCharCodes(
          _effectiveController!.text.runes.take(widget.pinLength));
    } else {
      _text = _effectiveController!.text;
    }

    widget.decoration.notifyChange(_text);
  }

  @override
  void initState() {
    super.initState();
    _cursorBlinkOpacityController =
        AnimationController(vsync: this, duration: widget.cursor.fadeDuration);
    _cursorBlinkOpacityController.addListener(_onCursorColorTick);
    _cursorVisibilityNotifier.value = widget.cursor.enabled;
    _effectiveFocusNode.addListener(_handleFocusChanged);
    if (widget.controller == null) {
      _controller = TextEditingController();
    }
    _effectiveController!.addListener(_pinChanged);

    //Ensure the initial value will be displayed when the field didn't get the focus.
    _updateText();
    _startOrStopCursorTimerIfNeeded();
  }

  void _onCursorColorTick() {
    if (widget.cursor.enabled) {
      _cursorColor =
          widget.cursor.color.withOpacity(_cursorBlinkOpacityController.value);
      _cursorVisibilityNotifier.value = _cursorBlinkOpacityController.value > 0;
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Ensure no listener will execute after dispose.
    _effectiveController!.removeListener(_pinChanged);
    _cursorBlinkOpacityController.removeListener(_onCursorColorTick);
    _stopCursorTimer();
    _effectiveFocusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(PinInputTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null && oldWidget.controller != null) {
      oldWidget.controller!.removeListener(_pinChanged);
      _controller =
          TextEditingController.fromValue(oldWidget.controller!.value);
      _controller!.addListener(_pinChanged);
    } else if (widget.controller != null && oldWidget.controller == null) {
      _controller!.removeListener(_pinChanged);
      _controller = null;
      widget.controller!.addListener(_pinChanged);
      // Invalidate the text when controller hold different old text.
      if (_text != widget.controller!.text) {
        _pinChanged();
      }
    } else if (widget.controller != oldWidget.controller) {
      // The old controller and current controller is not null and not the same.
      oldWidget.controller!.removeListener(_pinChanged);
      widget.controller!.addListener(_pinChanged);
    }

    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _focusNode)?.removeListener(_handleFocusChanged);
      (widget.focusNode ?? _focusNode)?.addListener(_handleFocusChanged);
    }

    /// If the newLength is shorter than now and the current text length longer
    /// than [pinLength], So we should cut the superfluous subString.
    if (oldWidget.pinLength > widget.pinLength &&
        _text.runes.length > widget.pinLength) {
      setState(() {
        _text = _text.substring(0, widget.pinLength);
        _effectiveController!.text = _text;
        _effectiveController!.selection =
            TextSelection.collapsed(offset: _text.runes.length);
      });
    }

    // make sure the the first time the decoration would take effective
    widget.decoration.notifyChange(_text);
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldTapRegion(
      onTapOutside: widget.tapRegionCallback,
      child: _buildTextField(),
    );
  }

  Widget _buildTextField() {
    _PinPaint pinPaint = _PinPaint(
      text: _text,
      pinLength: widget.pinLength,
      decoration: widget.decoration,
      themeData: Theme.of(context),
      cursor: widget.cursor.copyWith(color: _cursorColor),
      textDirection: Directionality.of(context),
    );
    return CustomPaint(
      /// The foreground paint to display pin.
      foregroundPainter: pinPaint,
      child: TextField(
        /// Actual textEditingController.
        controller: _effectiveController,

        /// Fake the text style.
        style: TextStyle(
          /// Hide the editing text.
          color: Colors.transparent,
          // To hide the cursor when in select mode
          fontSize: platformMiniFontSize(),
        ),

        /// Hide the Cursor
        showCursor: false,

        /// Autofill hints for the underlying platform.
        autofillHints: widget.autofillHints,

        /// Whether to correct the user input.
        autocorrect: widget.autocorrect,

        /// Center the input to make more natural.
        textAlign: TextAlign.center,

        /// Options of the edit menu
        contextMenuBuilder: widget.contextMenuBuilder,

        /// Disable the actual textField selection.
        enableInteractiveSelection: widget.enableInteractiveSelection,

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
        focusNode: _effectiveFocusNode,

        /// {@macro flutter.widgets.editableText.autofocus}
        autofocus: widget.autoFocus,

        /// The type of action button to use for the keyboard.
        ///
        /// Defaults to [TextInputAction.done]
        textInputAction: widget.textInputAction,

        onChanged: widget.onChanged,

        enabled: widget.enabled,

        textCapitalization: widget.textCapitalization,

        /// Clear default text decoration.
        decoration: InputDecoration(
          /// Hide the counterText
          counterText: '',

          /// Bind the error text from pin decoration to this input decoration.
          errorText: widget.decoration.errorText,

          /// Bind the style of error text from pin decoration to
          /// this input decoration.
          errorStyle: widget.decoration.errorTextStyle,

          // Disabled this as it doesn't show error or
          enabled: false,

          /// Hide the all border.
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  void _cursorTick(Timer timer) {
    _targetCursorVisibility = !_targetCursorVisibility;
    final double targetOpacity = _targetCursorVisibility ? 1.0 : 0.0;
    _cursorBlinkOpacityController.animateTo(targetOpacity,
        curve: Curves.easeOut);
  }

  void _cursorWaitForStart(Timer timer) {
    assert(widget.cursor.blinkHalfPeriod > widget.cursor.fadeDuration);
    _cursorTimer?.cancel();
    _cursorTimer = Timer.periodic(widget.cursor.blinkHalfPeriod, _cursorTick);
  }

  void _startCursorTimer() {
    _targetCursorVisibility = true;
    _cursorBlinkOpacityController.value = 1.0;
    _cursorTimer =
        Timer.periodic(widget.cursor.blinkWaitForStart, _cursorWaitForStart);
  }

  void _stopCursorTimer() {
    _cursorTimer?.cancel();
    _cursorTimer = null;
    _targetCursorVisibility = false;
    _cursorBlinkOpacityController.value = 0.0;
    _cursorBlinkOpacityController.stop();
    _cursorBlinkOpacityController.value = 0.0;
  }

  void _startOrStopCursorTimerIfNeeded() {
    if (_cursorTimer == null && _hasFocus && _value.selection.isCollapsed) {
      _startCursorTimer();
    } else if (_cursorTimer != null &&
        (!_hasFocus || !_value.selection.isCollapsed)) {
      _stopCursorTimer();
    }
  }

  bool get _hasFocus => _effectiveFocusNode.hasFocus;

  TextEditingValue get _value => _effectiveController!.value;

  void _handleFocusChanged() {
    _startOrStopCursorTimerIfNeeded();
  }
}

class _PinInputTextFormFieldState extends FormFieldState<String> {
  TextEditingController? _controller;

  TextEditingController? get _effectiveController =>
      widget.controller ?? _controller;

  @override
  PinInputTextFormField get widget => super.widget as PinInputTextFormField;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    }
    _effectiveController!.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(PinInputTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null && oldWidget.controller != null) {
      oldWidget.controller!.removeListener(_handleControllerChanged);
      _controller =
          TextEditingController.fromValue(oldWidget.controller!.value);
      _controller!.addListener(_handleControllerChanged);
    } else if (widget.controller != null && oldWidget.controller == null) {
      _controller!.removeListener(_handleControllerChanged);
      _controller = null;
      widget.controller!.addListener(_handleControllerChanged);
      // Invalidate the text when controller hold different old text.
      if (value != widget.controller!.text) {
        _handleControllerChanged();
      }
    } else if (widget.controller != oldWidget.controller) {
      // The old controller and current controller is not null and not the same.
      oldWidget.controller!.removeListener(_handleControllerChanged);
      widget.controller!.addListener(_handleControllerChanged);
    }

    /// If the newLength is shorter than now and the current text length longer
    /// than [pinLength], So we should cut the superfluous subString.
    if (oldWidget.pinLength > widget.pinLength &&
        value!.runes.length > widget.pinLength) {
      setState(() {
        setValue(value!.substring(0, widget.pinLength));
        _effectiveController!.text = value!;
        _effectiveController!.selection = TextSelection.collapsed(
          offset: value!.runes.length,
        );
      });
    }
  }

  @override
  void dispose() {
    _effectiveController!.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController!.text = widget.initialValue!;
    });
  }

  @override
  void didChange(String? value) {
    if (value!.runes.length > widget.pinLength) {
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
    if (_effectiveController!.text != value) {
      didChange(_effectiveController!.text);
    }
  }
}

class _PinPaint extends CustomPainter {
  final String text;
  final int pinLength;
  final PinEntryType type;
  final PinDecoration decoration;
  final ThemeData themeData;
  Cursor? cursor;
  TextDirection textDirection;

  _PinPaint({
    required this.text,
    required this.pinLength,
    required PinDecoration decoration,
    this.type = PinEntryType.boxTight,
    required this.themeData,
    this.cursor,
    this.textDirection = TextDirection.ltr,
  }) : decoration = decoration.copyWith(
    textStyle: decoration.textStyle ?? themeData.textTheme.headlineSmall,
    errorTextStyle: decoration.errorTextStyle ??
        themeData.textTheme.bodySmall
            ?.copyWith(color: themeData.colorScheme.error),
    hintTextStyle: decoration.hintTextStyle ??
        themeData.textTheme.headlineSmall
            ?.copyWith(color: themeData.hintColor),
  );

  @override
  bool shouldRepaint(_PinPaint oldDelegate) => oldDelegate != this;

  @override
  void paint(Canvas canvas, Size size) {
    // print('color: ${cursor.color} ${this.cursor.color}');
    decoration.drawPin(canvas, size, text, pinLength, cursor, textDirection);
  }

  _PinPaint copyWith({
    String? text,
    int? pinLength,
    PinDecoration? decoration,
    PinEntryType? type,
    ThemeData? themeData,
    Cursor? cursor,
  }) =>
      _PinPaint(
        text: text ?? this.text,
        pinLength: pinLength ?? this.pinLength,
        decoration: decoration ?? this.decoration,
        type: type ?? this.type,
        themeData: themeData ?? this.themeData,
        cursor: cursor ?? this.cursor,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is _PinPaint &&
              runtimeType == other.runtimeType &&
              text == other.text &&
              pinLength == other.pinLength &&
              type == other.type &&
              decoration == other.decoration &&
              themeData == other.themeData &&
              cursor == other.cursor;

  @override
  int get hashCode =>
      text.hashCode ^
      pinLength.hashCode ^
      type.hashCode ^
      decoration.hashCode ^
      themeData.hashCode ^
      cursor.hashCode;
}