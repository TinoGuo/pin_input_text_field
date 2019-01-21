library pin_input_text_field;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PinEntryType { underline, boxTight, boxLoose }

/// Default text style of displaying pin
const TextStyle _kDefaultStyle = TextStyle(
  /// Default text color.
  color: Colors.white,

  /// Default text size.
  fontSize: 24.0,
);

abstract class PinDecoration {
  /// The style of painting text.
  final TextStyle textStyle;

  final ObscureStyle obscureStyle;

  PinEntryType get pinEntryType;

  const PinDecoration({
    this.textStyle,
    this.obscureStyle,
  });
}

/// The object determine the obscure display
class ObscureStyle {
  /// Determine whether replace [obscureText] with number.
  final bool isTextObscure;

  /// The display text when [isTextObscure] is true
  final String obscureText;

  const ObscureStyle({
    this.isTextObscure: false,
    this.obscureText: '*',
  }) : assert(obscureText.length == 1);
}

/// The object determine the underline color etc.
class UnderlineDecoration extends PinDecoration {
  /// The space between text and underline.
  final double gapSpace;

  /// The color of the underline.
  final Color color;

  /// The height of the underline.
  final double lineHeight;

  /// The underline changed color when user enter pin.
  final Color enteredColor;

  const UnderlineDecoration({
    TextStyle textStyle,
    ObscureStyle obscureStyle,
    this.enteredColor,
    this.gapSpace: 16.0,
    this.color: Colors.cyan,
    this.lineHeight: 2.0,
  }) : super(
          textStyle: textStyle,
          obscureStyle: obscureStyle,
        );

  @override
  PinEntryType get pinEntryType => PinEntryType.underline;
}

/// The object determine the box stroke etc.
class BoxTightDecoration extends PinDecoration {
  /// The box border width.
  final double strokeWidth;

  /// The box border radius.
  final Radius radius;

  /// The box border color.
  final Color strokeColor;

  /// The box inside solid color.
  final Color solidColor;

  const BoxTightDecoration({
    TextStyle textStyle,
    ObscureStyle obscureStyle,
    this.solidColor,
    this.strokeWidth: 1.0,
    this.radius: const Radius.circular(8.0),
    this.strokeColor: Colors.cyan,
  }) : super(
          textStyle: textStyle,
          obscureStyle: obscureStyle,
        );

  @override
  PinEntryType get pinEntryType => PinEntryType.boxTight;
}

/// The object determine the box stroke etc.
class BoxLooseDecoration extends PinDecoration {
  /// The box border radius.
  final Radius radius;

  /// The box border width.
  final double strokeWidth;

  /// The adjacent box gap.
  final double gapSpace;

  /// The box border color.
  final Color strokeColor;

  /// The box inside solid color.
  final Color solidColor;

  /// The border changed color when user enter pin.
  final Color enteredColor;

  const BoxLooseDecoration({
    TextStyle textStyle,
    ObscureStyle obscureStyle,
    this.enteredColor,
    this.solidColor,
    this.radius: const Radius.circular(8.0),
    this.strokeWidth: 1.0,
    this.gapSpace: 16.0,
    this.strokeColor: Colors.cyan,
  }) : super(
          textStyle: textStyle,
          obscureStyle: obscureStyle,
        );

  @override
  PinEntryType get pinEntryType => PinEntryType.boxLoose;
}

/// Helper class to handle inner or outside controller.
class PinEditingController extends TextEditingController {
  /// Determine whether this class is defined inner.
  bool _inner;

  /// Control the maxLength of pin.
  int _pinMaxLength;

  PinEditingController._inner({String text, bool inner})
      : _inner = inner,
        super(text: text);

  PinEditingController({String text})
      : _inner = false,
        super(text: text);

  @override
  set text(String newText) {
    /// Cut the parameter string if the length is longer than [_pinMaxLength].
    if (newText != null &&
        _pinMaxLength != null &&
        newText.length > _pinMaxLength) {
      newText = newText.substring(0, _pinMaxLength);
    }
    super.text = newText;
  }
}

class PinInputTextField extends StatefulWidget {
  final double width;

  final double height;

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
  ///
  /// If null, this widget will create its own [PinEditingController].
  final PinEditingController pinEditingController;

  /// Same as [TextField]'s autoFocus.
  final bool autoFocus;

  /// Same as [TextField]'s focusNode.
  final FocusNode focusNode;

  PinInputTextField({
    this.pinLength: 6,
    this.width,
    this.height,
    this.onSubmit,
    this.decoration: const BoxLooseDecoration(),
    List<TextInputFormatter> inputFormatter,
    this.keyboardType: TextInputType.phone,
    pinEditingController,
    this.focusNode,
    this.autoFocus = false,
  })  : assert(pinLength > 0),
        inputFormatters = inputFormatter ??
            <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
        pinEditingController =
            pinEditingController ?? PinEditingController._inner(inner: false);

  @override
  State createState() {
    return _PinInputTextFieldState();
  }
}

class _PinInputTextFieldState extends State<PinInputTextField> {
  PinEditingController _controller;
  String _text;

  @override
  void initState() {
    super.initState();
    _controller = widget.pinEditingController;
    _controller._pinMaxLength = widget.pinLength;

    _controller.addListener(() {
      /// Reset the cursor position when in needed.
      /// Relevant issue see [https://github.com/flutter/flutter/issues/11416],
      /// Only work in Android.
      setState(() {
        _text = _controller.text;
        if (Platform.isAndroid &&
            _controller.text != null &&
            _controller.selection.start < _controller.text.length) {
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
      });
    });
  }

  @override
  void didUpdateWidget(PinInputTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the controller change from inside to outside,
    // we should dispose the controller to prevent leak;
    if (!_controller._inner && oldWidget.pinEditingController._inner) {
      oldWidget.pinEditingController.dispose();
    }
  }

  @override
  void dispose() {
    /// Only work in inner controller.
    if (_controller._inner) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        /// The foreground pain to display pin.
        foregroundPainter: _PinPaint(
          text: _text,
          pinLength: widget.pinLength,
          decoration: widget.decoration,
        ),
        child: TextField(
          /// Actual textEditingController.
          controller: _controller,
          style: TextStyle(
            /// Hide the editing text.
            color: Colors.transparent,
          ),

          /// Hide the Cursor.
          cursorColor: Colors.transparent,

          /// Hide the cursor.
          cursorWidth: 0.0,

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

          focusNode: widget.focusNode,

          autofocus: widget.autoFocus,

          /// Clear default text decoration.
          decoration: InputDecoration(
            /// Hide the counterText
            counterText: '',

            /// Hide the outline border.
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _PinPaint extends CustomPainter {
  String text;
  final int pinLength;
  final double space;
  final PinEntryType type;
  final PinDecoration decoration;

  _PinPaint({
    String text,
    this.pinLength,
    this.decoration,
    this.space: 4.0,
    this.type: PinEntryType.boxTight,
  }) {
    text ??= "";
    this.text = text.trim();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) =>
      !(oldDelegate is _PinPaint && oldDelegate.text == this.text);

  _drawBoxTight(Canvas canvas, Size size) {
    /// Force convert to [BoxTightDecoration].
    var dr = decoration as BoxTightDecoration;
    Paint borderPaint = Paint()
      ..color = dr.strokeColor
      ..strokeWidth = dr.strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    /// Assign paint if [solidColor] is not null
    Paint insidePaint;
    if (dr.solidColor != null) {
      insidePaint = Paint()
        ..color = dr.solidColor
        ..strokeWidth = dr.strokeWidth
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
    }

    Rect rect = Rect.fromLTRB(
      dr.strokeWidth / 2,
      dr.strokeWidth / 2,
      size.width - dr.strokeWidth / 2,
      size.height - dr.strokeWidth / 2,
    );

    if (insidePaint != null) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, dr.radius), insidePaint);
    }

    /// Draw the whole rect.
    canvas.drawRRect(RRect.fromRectAndRadius(rect, dr.radius), borderPaint);

    /// Calculate the width of each underline.
    double singleWidth =
        (size.width - dr.strokeWidth * (pinLength + 1)) / pinLength;

    for (int i = 1; i < pinLength; i++) {
      double offsetX = singleWidth +
          dr.strokeWidth * i +
          dr.strokeWidth / 2 +
          singleWidth * (i - 1);
      canvas.drawLine(Offset(offsetX, dr.strokeWidth),
          Offset(offsetX, size.height - dr.strokeWidth), borderPaint);
    }

    /// The char index of the [text]
    var index = 0;
    var startY = 0.0;
    var startX = 0.0;

    /// Determine whether display obscureText.
    bool obscureOn;
    obscureOn = decoration.obscureStyle != null &&
        decoration.obscureStyle.isTextObscure;

    /// The text style of pin.
    TextStyle textStyle;
    if (decoration.textStyle == null) {
      textStyle = _kDefaultStyle;
    } else {
      textStyle = decoration.textStyle;
    }

    text.runes.forEach((rune) {
      String code;
      if (obscureOn) {
        code = decoration.obscureStyle.obscureText;
      } else {
        code = String.fromCharCode(rune);
      }
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          style: textStyle,
          text: code,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      /// Layout the text.
      textPainter.layout();

      /// No need to compute again
      if (startY == 0.0) {
        startY = size.height / 2 - textPainter.height / 2;
      }
      startX = dr.strokeWidth * (index + 1) +
          singleWidth * index +
          singleWidth / 2 -
          textPainter.width / 2;
      textPainter.paint(canvas, Offset(startX, startY));
      index++;
    });
  }

  _drawBoxLoose(Canvas canvas, Size size) {
    /// Force convert to [BoxLooseDecoration].
    var dr = decoration as BoxLooseDecoration;
    Paint borderPaint = Paint()
      ..color = dr.strokeColor
      ..strokeWidth = dr.strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    /// Assign paint if [solidColor] is not null
    Paint insidePaint;
    if (dr.solidColor != null) {
      insidePaint = Paint()
        ..color = dr.solidColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
    }

    /// Calculate the width of each underline.
    double singleWidth = (size.width -
            dr.strokeWidth * 2 * pinLength -
            ((pinLength - 1) * dr.gapSpace)) /
        pinLength;

    var startX = dr.strokeWidth / 2;
    var startY = size.height - dr.strokeWidth / 2;

    /// Draw the each rect of pin.
    for (int i = 0; i < pinLength; i++) {
      if (i < text.length && dr.enteredColor != null) {
        borderPaint.color = dr.enteredColor;
      } else {
        borderPaint.color = dr.strokeColor;
      }
      RRect rRect = RRect.fromRectAndRadius(
          Rect.fromLTRB(
            startX,
            dr.strokeWidth / 2,
            startX + singleWidth + dr.strokeWidth,
            startY,
          ),
          dr.radius);
      canvas.drawRRect(rRect, borderPaint);
      if (insidePaint != null) {
        canvas.drawRRect(rRect, insidePaint);
      }
      startX += singleWidth + dr.gapSpace + dr.strokeWidth * 2;
    }

    /// The char index of the [text]
    var index = 0;
    startY = 0.0;

    /// Determine whether display obscureText.
    bool obscureOn;
    obscureOn = decoration.obscureStyle != null &&
        decoration.obscureStyle.isTextObscure;

    /// The text style of pin.
    TextStyle textStyle;
    if (decoration.textStyle == null) {
      textStyle = _kDefaultStyle;
    } else {
      textStyle = decoration.textStyle;
    }

    text.runes.forEach((rune) {
      String code;
      if (obscureOn) {
        code = decoration.obscureStyle.obscureText;
      } else {
        code = String.fromCharCode(rune);
      }
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          style: textStyle,
          text: code,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      /// Layout the text.
      textPainter.layout();

      /// No need to compute again
      if (startY == 0.0) {
        startY = size.height / 2 - textPainter.height / 2;
      }
      startX = singleWidth * index +
          singleWidth / 2 -
          textPainter.width / 2 +
          dr.gapSpace * index +
          dr.strokeWidth * index * 2 +
          dr.strokeWidth;
      textPainter.paint(canvas, Offset(startX, startY));
      index++;
    });
  }

  _drawUnderLine(Canvas canvas, Size size) {
    /// Force convert to [UnderlineDecoration].
    var dr = decoration as UnderlineDecoration;
    Paint underlinePaint = Paint()
      ..color = dr.color
      ..strokeWidth = dr.lineHeight
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    var startX = 0.0;
    var startY = size.height - dr.lineHeight;

    /// Calculate the width of each underline.
    double singleWidth =
        (size.width - (pinLength - 1) * dr.gapSpace) / pinLength;

    for (int i = 0; i < pinLength; i++) {
      if (i < text.length && dr.enteredColor != null) {
        underlinePaint.color = dr.enteredColor;
      } else {
        underlinePaint.color = dr.color;
      }
      canvas.drawLine(Offset(startX, startY),
          Offset(startX + singleWidth, startY), underlinePaint);
      startX += singleWidth + dr.gapSpace;
    }

    /// The char index of the [text]
    var index = 0;
    startX = 0.0;
    startY = 0.0;

    /// Determine whether display obscureText.
    bool obscureOn;
    obscureOn = decoration.obscureStyle != null &&
        decoration.obscureStyle.isTextObscure;

    /// The text style of pin.
    TextStyle textStyle;
    if (decoration.textStyle == null) {
      textStyle = _kDefaultStyle;
    } else {
      textStyle = decoration.textStyle;
    }

    text.runes.forEach((rune) {
      String code;
      if (obscureOn) {
        code = decoration.obscureStyle.obscureText;
      } else {
        code = String.fromCharCode(rune);
      }
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          style: textStyle,
          text: code,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      /// Layout the text.
      textPainter.layout();

      /// No need to compute again
      if (startY == 0.0) {
        startY = size.height / 2 - textPainter.height / 2;
      }
      startX = singleWidth * index +
          singleWidth / 2 -
          textPainter.width / 2 +
          dr.gapSpace * index;
      textPainter.paint(canvas, Offset(startX, startY));
      index++;
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (decoration.pinEntryType) {
      case PinEntryType.boxTight:
        {
          _drawBoxTight(canvas, size);
          break;
        }
      case PinEntryType.boxLoose:
        {
          _drawBoxLoose(canvas, size);
          break;
        }
      case PinEntryType.underline:
        {
          _drawUnderLine(canvas, size);
          break;
        }
    }
  }
}
