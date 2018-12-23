library pin_input_text_field;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PinEntryType { underline, boxTight, boxLoose }

const TextStyle _kDefaultStyle = TextStyle(
  color: Colors.white,
  fontSize: 24.0,
);

abstract class PinDecoration {
  /// The style of painting text.
  final TextStyle textStyle;

  /// Determine replace * with number.
  final bool isTextObscure;

  PinEntryType get pinEntryType;

  const PinDecoration({
    this.textStyle,
    this.isTextObscure,
  });
}

class UnderlineDecoration extends PinDecoration {
  final double lineSpace;
  final double gapSpace;
  final Color color;
  final double lineHeight;

  const UnderlineDecoration({
    textStyle: _kDefaultStyle,
    isTextObscure: false,
    this.lineSpace: 8.0,
    this.gapSpace: 16.0,
    this.color: Colors.black,
    this.lineHeight: 2.0,
  }) : super(
          textStyle: textStyle,
          isTextObscure: isTextObscure,
        );

  @override
  PinEntryType get pinEntryType => PinEntryType.underline;
}

class BoxTightDecoration extends PinDecoration {
  final double strokeWidth;
  final Radius radius;
  final Color strokeColor;

  const BoxTightDecoration({
    TextStyle textStyle: _kDefaultStyle,
    bool isTextObscure: false,
    this.strokeWidth: 1.0,
    this.radius: const Radius.circular(8.0),
    this.strokeColor: Colors.cyan,
  }) : super(
          textStyle: textStyle,
          isTextObscure: isTextObscure,
        );

  @override
  PinEntryType get pinEntryType => PinEntryType.boxTight;
}

class BoxLooseDecoration extends PinDecoration {
  final Radius radius;
  final double strokeWidth;
  final double gapSpace;
  final Color strokeColor;

  const BoxLooseDecoration({
    textStyle: _kDefaultStyle,
    isTextObscure: false,
    this.radius: const Radius.circular(8.0),
    this.strokeWidth: 1.0,
    this.gapSpace: 16.0,
    this.strokeColor: Colors.cyan,
  }) : super(
          textStyle: textStyle,
          isTextObscure: isTextObscure,
        );

  @override
  PinEntryType get pinEntryType => PinEntryType.boxLoose;
}

class PinInputTextField extends StatefulWidget {
  /// The max length of pin.
  final int pinLength;

  /// The user click done.
  final ValueChanged<String> onSubmit;
  final double width;
  final double height;

  /// Decorate the number.
  final PinDecoration decoration;

  PinInputTextField({
    this.pinLength: 6,
    this.width,
    this.height,
    this.onSubmit,
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
        foregroundPainter: _PinPaint(
          text: _text,
          pinLength: widget.pinLength,
          decoration: widget.decoration,
        ),
        child: TextField(
          controller: _controller,
          style: TextStyle(
            /// Hide the editing text.
            color: Colors.transparent,
          ),

          /// Hide the Cursor.
          cursorColor: Colors.transparent,

          /// Hide the cursor.
          cursorWidth: 0.0,
          maxLength: widget.pinLength,
          onSubmitted: widget.onSubmit,
          keyboardType: TextInputType.numberWithOptions(signed: true),
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
    var dr = decoration as BoxTightDecoration;
    Paint borderPaint = Paint()
      ..color = dr.strokeColor
      ..strokeWidth = dr.strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    Rect rect = Rect.fromLTRB(
        dr.strokeWidth, 0.0, size.width - dr.strokeWidth, size.height);

    canvas.drawRRect(RRect.fromRectAndRadius(rect, dr.radius), borderPaint);

    double singleWidth = (size.width - dr.strokeWidth * 2) / pinLength;

    for (int i = 0; i < pinLength - 1; i++) {
      canvas.drawLine(Offset(singleWidth * (i + 1), 0),
          Offset(singleWidth * (i + 1), size.height), borderPaint);
    }

    if (text == null || text.trim().isEmpty) {
      return;
    }
    var index = 0;
    var startY = 0.0;
    var startX = 0.0;
    text.runes.forEach((rune) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          style: decoration.textStyle,
          text: decoration.isTextObscure ? '*' : String.fromCharCode(rune),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
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
    var dr = decoration as BoxLooseDecoration;
    Paint borderPaint = Paint()
      ..color = dr.strokeColor
      ..strokeWidth = dr.strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    double singleWidth =
        (size.width - dr.strokeWidth * 2 - ((pinLength - 1) * dr.gapSpace)) /
            pinLength;

    var startX = dr.strokeWidth;
    var startY = size.height - dr.strokeWidth;
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

    if (text == null || text.trim().isEmpty) {
      return;
    }
    var index = 0;
    startY = 0.0;
    text.runes.forEach((rune) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          style: decoration.textStyle,
          text: decoration.isTextObscure ? '*' : String.fromCharCode(rune),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
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
    var dr = decoration as UnderlineDecoration;
    Paint underlinePaint = Paint()
      ..color = dr.color
      ..strokeWidth = dr.lineHeight
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    var startX = 0.0;
    var startY = size.height - dr.lineHeight;
    double singleWidth =
        (size.width - (pinLength - 1) * dr.gapSpace) / pinLength;

    for (int i = 0; i < pinLength; i++) {
      canvas.drawLine(Offset(startX, startY),
          Offset(startX + singleWidth, startY), underlinePaint);
      startX += singleWidth + dr.gapSpace;
    }

    if (text == null || text.trim().isEmpty) {
      return;
    }

    var index = 0;
    startX = 0.0;
    startY = 0.0;
    text.runes.forEach((rune) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          style: decoration.textStyle,
          text: decoration.isTextObscure ? '*' : String.fromCharCode(rune),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
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
