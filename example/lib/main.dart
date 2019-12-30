import 'package:flutter/material.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

void main() => runApp(MyApp());

const _kInputHeight = 64.0;
const _kDefaultHint = 'abcd';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pin Demo',
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
  MyHomePage(this.textFieldType, {Key key}) : super(key: key);

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
  TextEditingController _pinEditingController =
      TextEditingController(text: '123');

  GlobalKey<ScaffoldState> _globalKey =
      GlobalKey<ScaffoldState>(debugLabel: 'home page global key');

  /// Decorate the outside of the Pin.
  PinDecoration _pinDecoration = UnderlineDecoration(
    enteredColor: Colors.green,
    hintText: _kDefaultHint,
  );

  /// Control whether show the obscureCode.
  bool _obscureEnable = false;

  PinEntryType _pinEntryType = PinEntryType.underline;
  Color _solidColor = Colors.purpleAccent;
  bool _solidEnable = false;

  /// Control whether textField is enable.
  bool _enable = true;

  /// Indicate whether the PinInputTextFormField has error or not
  /// after being validated.
  bool _hasError = false;

  /// Set a pin to the textField.
  void _setPinValue() {
    var text = _generatePin();
    _pinEditingController
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.runes.length);
  }

  String _generatePin() {
    StringBuffer sb = StringBuffer();
    for (int i = 1; i <= _pinLength; i++) {
      sb.write("$i");
    }
    return sb.toString();
  }

  @override
  void initState() {
    _pinEditingController.addListener(() {
      debugPrint('controller execute. pin:${_pinEditingController.text}');
    });
    super.initState();
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
            enteredColor: Colors.green,
            obscureStyle: ObscureStyle(
              isTextObscure: _obscureEnable,
              obscureText: '😂',
            ),
            hintText: _kDefaultHint,
          );
        });
        break;
      case PinEntryType.boxTight:
        setState(() {
          _pinDecoration = BoxTightDecoration(
            solidColor: _solidEnable ? _solidColor : null,
            obscureStyle: ObscureStyle(
              isTextObscure: _obscureEnable,
              obscureText: '👿',
            ),
            hintText: _kDefaultHint,
          );
        });
        break;
      case PinEntryType.boxLoose:
        setState(() {
          _pinDecoration = BoxLooseDecoration(
            enteredColor: Colors.green,
            solidColor: _solidEnable ? _solidColor : null,
            obscureStyle: ObscureStyle(
              isTextObscure: _obscureEnable,
              obscureText: '☺️',
            ),
            hintText: _kDefaultHint,
          );
        });
        break;
      case PinEntryType.circle:
        setState(() {
          _pinDecoration = CirclePinDecoration(
            enteredColor: Colors.green,
            solidColor: _solidEnable ? _solidColor : null,
            strokeColor: Colors.black,
            strokeWidth: 4,
            obscureStyle: ObscureStyle(
              isTextObscure: _obscureEnable,
              obscureText: '🤪',
            ),
            hintText: _kDefaultHint,
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
                  if (_pinEntryType == PinEntryType.underline) {
                    _globalKey.currentState.showSnackBar(SnackBar(
                        content: Text(
                            'solid control isn\'t supported in Underline mode')));
                  }
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
    ];
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
              decoration: _pinDecoration,
              controller: _pinEditingController,
              textInputAction: TextInputAction.go,
              enabled: _enable,
              onSubmit: (pin) {
                debugPrint('submit pin:$pin');
              },
              onChanged: (pin) {
                debugPrint('onChanged execute. pin:$pin');
              },
            ),
          ),
        ],
      ),
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
              decoration: _pinDecoration,
              controller: _pinEditingController,
              textInputAction: TextInputAction.go,
              enabled: _enable,
              onSubmit: (pin) {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                }
              },
              onChanged: (pin) {
                debugPrint('onChanged execute. pin:$pin');
              },
              onSaved: (pin) {
                debugPrint('onSaved pin:$pin');
              },
              validator: (pin) {
                if (pin.isEmpty) {
                  setState(() {
                    _hasError = true;
                  });
                  return 'Pin cannot empty.';
                }
                setState(() {
                  _hasError = false;
                });
                return null;
              },
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                  }
                },
                child: Text('Submit'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                textColor: Colors.white,
                color: _hasError ? Colors.red : Colors.green,
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
              return [
                PopupMenuItem(
                  child: Text('underline decoration'),
                  value: PinEntryType.underline,
                ),
                PopupMenuItem(
                  child: Text('box loose decoration'),
                  value: PinEntryType.boxLoose,
                ),
                PopupMenuItem(
                  child: Text('box tight decoration'),
                  value: PinEntryType.boxTight,
                ),
                PopupMenuItem(
                  child: Text('circle decoration'),
                  value: PinEntryType.circle,
                ),
                PopupMenuItem(
                  child: Text('Customize decorarion'),
                  value: PinEntryType.customized,
                )
              ];
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
    TextStyle textStyle,
    ObscureStyle obscureStyle,
    String errorText,
    TextStyle errorTextStyle,
    String hintText,
    TextStyle hintTextStyle,
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
    TextStyle textStyle,
    ObscureStyle obscureStyle,
    String errorText,
    TextStyle errorTextStyle,
    String hintText,
    TextStyle hintTextStyle,
  }) {
    return ExampleDecoration(
      textStyle: textStyle ?? this.textStyle,
      obscureStyle: obscureStyle ?? this.obscureStyle,
      errorText: errorText ?? this.errorText,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      hintText: hintText ?? this.hintText,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
    );
  }

  @override
  void drawPin(
    Canvas canvas,
    Size size,
    String text,
    pinLength,
    ThemeData themeData,
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
