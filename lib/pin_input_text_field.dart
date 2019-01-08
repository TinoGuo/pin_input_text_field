library pin_input_text_field;

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

  const UnderlineDecoration({
    TextStyle textStyle,
    ObscureStyle obscureStyle,
    this.gapSpace: 16.0,
    this.color: Colors.black,
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

  const BoxTightDecoration({
    TextStyle textStyle,
    ObscureStyle obscureStyle,
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

  const BoxLooseDecoration({
    TextStyle textStyle,
    ObscureStyle obscureStyle,
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

class PinInputTextField extends StatefulWidget {
  /// The max length of pin.
  final int pinLength;

  /// The callback will execute when user click done.
  final ValueChanged<String> onSubmit;

  /// The callback will execute when user input.
  final ValueChanged<String> onPinChanged;

  final double width;

  final double height;

  /// Decorate the pin.
  final PinDecoration decoration;

  PinInputTextField({
    this.pinLength: 6,
    this.width,
    this.height,
    this.onSubmit,
    this.onPinChanged,
    this.decoration: const BoxLooseDecoration(),
  }) : assert(pinLength > 0);

  @override
  State createState() {
    return _PinInputTextFieldState();
  }
}

class _PinInputTextFieldState extends State<PinInputTextField> {
  final TextEditingController _controller = TextEditingController();
  String _text;

  /// The current string the user is editing.
  String get text => _text;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _text = _controller.text;
        if (widget.onPinChanged != null) {
          widget.onPinChanged(_text);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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

          /// The maxLength of the pin input, the default value is 6
          maxLength: widget.pinLength,

          /// If use system keyboard and user click done, it will execute callback
          /// Note!!! Custom keyboard in Android will not execute, see the related issue [https://github.com/flutter/flutter/issues/19027]
          onSubmitted: widget.onSubmit,

          /// Default text input type is number
          keyboardType: TextInputType.numberWithOptions(signed: true),

          /// only accept digits
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly,
          ],
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
  final String text;
  final int pinLength;
  final double space;
  final PinEntryType type;
  final PinDecoration decoration;

  _PinPaint({
    this.text,
    this.pinLength,
    this.decoration,
    this.space: 4.0,
    this.type: PinEntryType.boxTight,
  });

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

    Rect rect = Rect.fromLTRB(
        dr.strokeWidth, 0.0, size.width - dr.strokeWidth, size.height);

    /// Draw the whole rect.
    canvas.drawRRect(RRect.fromRectAndRadius(rect, dr.radius), borderPaint);

    /// Calculate the width of each underline.
    double singleWidth = (size.width - dr.strokeWidth * 2) / pinLength;

    for (int i = 0; i < pinLength - 1; i++) {
      canvas.drawLine(Offset(singleWidth * (i + 1), 0),
          Offset(singleWidth * (i + 1), size.height), borderPaint);
    }

    /// Do not draw the text when text is blank.
    if (text == null || text.trim().isEmpty) {
      return;
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
      startX = singleWidth * index + singleWidth / 2 - textPainter.width / 2;
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

    /// Calculate the width of each underline.
    double singleWidth =
        (size.width - dr.strokeWidth * 2 - ((pinLength - 1) * dr.gapSpace)) /
            pinLength;

    var startX = dr.strokeWidth;
    var startY = size.height - dr.strokeWidth;

    /// Draw the each rect of pin.
    for (int i = 0; i < pinLength; i++) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTRB(
                startX,
                dr.strokeWidth,
                startX + singleWidth,
                startY,
              ),
              dr.radius),
          borderPaint);
      startX += singleWidth + dr.gapSpace;
    }

    /// Do not draw the text when text is blank.
    if (text == null || text.trim().isEmpty) {
      return;
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
          dr.gapSpace * index;
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
      canvas.drawLine(Offset(startX, startY),
          Offset(startX + singleWidth, startY), underlinePaint);
      startX += singleWidth + dr.gapSpace;
    }

    /// Do not draw the text when text is blank.
    if (text == null || text.trim().isEmpty) {
      return;
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