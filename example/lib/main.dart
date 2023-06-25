import 'package:flutter/material.dart' hide Orientation;
import 'package:pin_input_text_field/pin_input_text_field.dart';

void main() => runApp(MyApp());

const _kInputHeight = 64.0;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pin Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListPage(),
    );
  }
}

enum TextFieldType {
  NORMAL,
  FORM,
}

class ListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('demo'),
      ),
      body: ListView.builder(
        itemCount: TextFieldType.values.length,
        itemBuilder: (ctx, index) {
          return ListTile(
            title: Text(TextFieldType.values[index].toString()),
            onTap: () {
              Navigator.push(
                  ctx,
                  MaterialPageRoute(
                      builder: (context) =>
                          MyHomePage(TextFieldType.values[index])));
            },
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage(this.textFieldType, {Key? key}) : super(key: key);

  final TextFieldType textFieldType;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Default max pin length.
  static final int _pinLength = 4;

  /// PinInputTextFormField form-key
  final GlobalKey<FormFieldState<String>> _formKey =
      GlobalKey<FormFieldState<String>>(debugLabel: '_formkey');

  /// Control the input text field.
  TextEditingController _pinEditingController = TextEditingController(text: '');

  GlobalKey<ScaffoldState> _globalKey =
      GlobalKey<ScaffoldState>(debugLabel: 'home page global key');

  /// Decorate the outside of the Pin.
  PinDecoration? _pinDecoration;

  /// Control whether show the obscureCode.
  bool? _obscureEnable = false;

  PinEntryType _pinEntryType = PinEntryType.underline;
  ColorBuilder _solidColor =
      PinListenColorBuilder(Colors.grey, Colors.grey[400]!);
  bool? _solidEnable = false;

  /// Control whether textField is enable.
  bool? _enable = true;

  /// Indicate whether the PinInputTextFormField has error or not
  /// after being validated.
  bool _hasError = false;

  bool? _cursorEnable = true;

  Orientation _orientation = Orientation.vertical;

  /// Set a pin to the textField.
  void _setPinValue() {
    _pinEditingController
      ..text = "0000"
      ..selection = TextSelection.collapsed(offset: 4);
  }

  @override
  void initState() {
    _pinEditingController.addListener(() {
      debugPrint('controller execute. pin:${_pinEditingController.text}');
    });
    super.initState();
    _selectedMenu(PinEntryType.underline);
  }

  @override
  void dispose() {
    _pinEditingController.dispose();
    super.dispose();
  }

  void _selectedMenu(PinEntryType type) {
    _pinEntryType = type;
    switch (type) {
      case PinEntryType.underline:
        setState(() {
          _pinDecoration = UnderlineDecoration(
            colorBuilder: PinListenColorBuilder(Colors.cyan, Colors.green),
            bgColorBuilder: _solidEnable! ? _solidColor : null,
            obscureStyle: ObscureStyle(
              isTextObscure: _obscureEnable!,
              obscureText: '😂',
            ),
          );
        });
        break;
      case PinEntryType.boxTight:
        setState(() {
          _pinDecoration = BoxTightDecoration(
            bgColorBuilder: _solidEnable! ? _solidColor : null,
            obscureStyle: ObscureStyle(
              isTextObscure: _obscureEnable!,
              obscureText: '👿',
            ),
          );
        });
        break;
      case PinEntryType.boxLoose:
        setState(() {
          _pinDecoration = BoxLooseDecoration(
            strokeColorBuilder:
                PinListenColorBuilder(Colors.cyan, Colors.green),
            bgColorBuilder: _solidEnable! ? _solidColor : null,
            obscureStyle: ObscureStyle(
              isTextObscure: _obscureEnable!,
              obscureText: '☺️',
            ),
          );
        });
        break;
      case PinEntryType.circle:
        setState(() {
          _pinDecoration = CirclePinDecoration(
            bgColorBuilder: _solidEnable! ? _solidColor : null,
            strokeColorBuilder:
                PinListenColorBuilder(Colors.cyan, Colors.green),
            obscureStyle: ObscureStyle(
              isTextObscure: _obscureEnable!,
              obscureText: '🤪',
            ),
          );
        });
        break;
      case PinEntryType.customized:
        setState(() {
          _pinDecoration = ExampleDecoration();
        });
        break;
    }
  }

  _buildExampleBody() {
    switch (widget.textFieldType) {
      case TextFieldType.NORMAL:
        return _buildPinInputTextFieldExample();
      case TextFieldType.FORM:
        return _buildPinInputTextFormFieldExample();
    }
  }

  _buildConfigWidget() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'obscureEnabled',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Checkbox(
              value: _obscureEnable,
              onChanged: (enable) {
                setState(() {
                  _obscureEnable = enable;
                  _selectedMenu(_pinEntryType);
                });
              }),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'solidEnabled',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Checkbox(
              value: _solidEnable,
              onChanged: (enable) {
                setState(() {
                  _solidEnable = enable;
                  _selectedMenu(_pinEntryType);
                });
              }),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'enabled',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(width: 12),
          Checkbox(
            value: _enable,
            onChanged: (enable) {
              setState(() {
                _enable = enable;
              });
            },
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'cursor enabled',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(width: 12),
          Checkbox(
            value: _cursorEnable,
            onChanged: (enable) {
              setState(() {
                _cursorEnable = enable;
              });
            },
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Cursor orientation',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(width: 12),
          PopupMenuButton<Orientation>(
            child: Icon(_orientation == Orientation.vertical
                ? Icons.stay_current_portrait
                : Icons.stay_current_landscape),
            onSelected: _cursorOrientationSelected,
            itemBuilder: (context) => Orientation.values
                .map((e) => PopupMenuItem(value: e, child: Text(e.name)))
                .toList(growable: false),
          )
        ],
      ),
    ];
  }

  void _cursorOrientationSelected(Orientation orientation) {
    setState(() {
      _orientation = orientation;
    });
  }

  Widget _buildPinInputTextFieldExample() {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: ListView(
        children: <Widget>[
          ..._buildConfigWidget(),
          SizedBox(
            height: _kInputHeight,
            child: PinInputTextField(
              pinLength: _pinLength,
              decoration: _pinDecoration!,
              controller: _pinEditingController,
              textInputAction: TextInputAction.go,
              enabled: _enable!,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              onSubmit: (pin) {
                debugPrint('submit pin:$pin');
              },
              onChanged: (pin) {
                debugPrint('onChanged execute. pin:$pin');
              },
              enableInteractiveSelection: false,
              cursor: _orientation == Orientation.vertical
                  ? _buildVerticalCursor()
                  : _buildHorizontalCursor(),
            ),
          ),
        ],
      ),
    );
  }

  Cursor _buildVerticalCursor() {
    return Cursor(
      width: 2,
      color: Colors.lightBlue,
      radius: Radius.circular(1),
      enabled: _cursorEnable!,
      orientation: Orientation.vertical,
    );
  }

  Cursor _buildHorizontalCursor() {
    return Cursor(
      height: 2,
      width: 64,
      offset: 16,
      color: Colors.lightBlue,
      radius: Radius.circular(1),
      enabled: _cursorEnable!,
      orientation: Orientation.horizontal,
    );
  }

  Widget _buildPinInputTextFormFieldExample() {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: ListView(
        children: <Widget>[
          ..._buildConfigWidget(),
          SizedBox(
            height: _kInputHeight,
            child: PinInputTextFormField(
              key: _formKey,
              pinLength: _pinLength,
              decoration: _pinDecoration!,
              controller: _pinEditingController,
              textInputAction: TextInputAction.go,
              enabled: _enable!,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              onSubmit: (pin) {
                if (_formKey.currentState?.validate() == true) {
                  _formKey.currentState?.save();
                }
              },
              onChanged: (pin) {
                debugPrint('onChanged execute. pin:$pin');
              },
              onSaved: (pin) {
                debugPrint('onSaved pin:$pin');
              },
              validator: (pin) {
                if (pin?.isEmpty == true) {
                  setState(() {
                    _hasError = true;
                  });
                  return 'Pin cannot empty.';
                }
                if (pin!.length < _pinLength) {
                  setState(() {
                    _hasError = true;
                  });
                  return 'Pin is not completed.';
                }
                setState(() {
                  _hasError = false;
                });
                return null;
              },
              cursor: _orientation == Orientation.vertical ? _buildVerticalCursor() : _buildHorizontalCursor(),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() == true) {
                    _formKey.currentState?.save();
                  }
                },
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: _hasError ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text(widget.textFieldType.toString()),
        actions: <Widget>[
          PopupMenuButton<PinEntryType>(
            icon: Icon(Icons.more_vert),
            onSelected: _selectedMenu,
            itemBuilder: (context) {
              return PinEntryType.values
                  .map((e) => PopupMenuItem(
                        child: Text(e.name),
                        value: e,
                      ))
                  .toList(growable: false);
            },
          ),
        ],
      ),
      body: _buildExampleBody(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        tooltip: 'set new value',
        onPressed: () {
          _setPinValue();
        },
      ),
    );
  }
}

class ExampleDecoration extends PinDecoration {
  ExampleDecoration({
    TextStyle? textStyle,
    ObscureStyle? obscureStyle,
    String? errorText,
    TextStyle? errorTextStyle,
    String? hintText,
    TextStyle? hintTextStyle,
    ColorBuilder? bgColorBuilder,
  }) : super(
          textStyle: textStyle,
          obscureStyle: obscureStyle,
          errorText: errorText,
          errorTextStyle: errorTextStyle,
          hintText: hintText,
          hintTextStyle: hintTextStyle,
        );

  @override
  PinDecoration copyWith({
    TextStyle? textStyle,
    ObscureStyle? obscureStyle,
    String? errorText,
    TextStyle? errorTextStyle,
    String? hintText,
    TextStyle? hintTextStyle,
    ColorBuilder? bgColorBuilder,
  }) {
    return ExampleDecoration(
        textStyle: textStyle ?? this.textStyle,
        obscureStyle: obscureStyle ?? this.obscureStyle,
        errorText: errorText ?? this.errorText,
        errorTextStyle: errorTextStyle ?? this.errorTextStyle,
        hintText: hintText ?? this.hintText,
        hintTextStyle: hintTextStyle ?? this.hintTextStyle,
        bgColorBuilder: bgColorBuilder);
  }

  @override
  void notifyChange(String pin) {}

  @override
  void drawPin(
    Canvas canvas,
    Size size,
    String text,
    int pinLength,
    Cursor? cursor,
    TextDirection textDirection,
  ) {
    /// You can draw anything you want here.
    canvas.drawLine(
      Offset.zero,
      Offset(size.width, size.height),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true,
    );
  }

  @override
  PinEntryType get pinEntryType => PinEntryType.customized;
}
