import 'package:flutter/material.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

void main() => runApp(MyApp());

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

  /// Default Text style.
  static const TextStyle _textStyle = TextStyle(
    color: Colors.black,
    fontSize: 24,
  );

  /// PinInputTextFormField form-key
  final GlobalKey<FormFieldState<String>> _formKey =
      GlobalKey<FormFieldState<String>>(debugLabel: '_formkey');

  /// Control the input text field.
  TextEditingController _pinEditingController =
      TextEditingController(text: '123');

  /// Decorate the outside of the Pin.
  PinDecoration _pinDecoration = UnderlineDecoration(
    textStyle: _textStyle,
    enteredColor: Colors.green,
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
      debugPrint('changed pin:${_pinEditingController.text}');
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
            textStyle: _textStyle,
            enteredColor: Colors.green,
            obscureStyle: ObscureStyle(
              isTextObscure: _obscureEnable,
              obscureText: '😂',
            ),
          );
        });
        break;
      case PinEntryType.boxTight:
        setState(() {
          _pinDecoration = BoxTightDecoration(
            textStyle: _textStyle,
            solidColor: _solidEnable ? _solidColor : null,
            obscureStyle: ObscureStyle(
              isTextObscure: _obscureEnable,
              obscureText: '👿',
            ),
          );
        });
        break;
      case PinEntryType.boxLoose:
        setState(() {
          _pinDecoration = BoxLooseDecoration(
            textStyle: _textStyle,
            enteredColor: Colors.green,
            solidColor: _solidEnable ? _solidColor : null,
            obscureStyle: ObscureStyle(
              isTextObscure: _obscureEnable,
              obscureText: '☺️',
            ),
          );
        });
        break;
    }
  }

  // ignore: unused_element
  Widget _buildInListView() {
    return ListView(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Icon(Icons.edit),
            Text('1'),
            Expanded(
              child: PinInputTextField(
                decoration: BoxLooseDecoration(
                    textStyle: TextStyle(color: Colors.black)),
                autoFocus: false,
                pinLength: 4,
                controller: _pinEditingController,
              ),
            ),
          ],
        ),
        PinInputTextField(
          pinLength: 4,
          autoFocus: false,
          decoration: BoxLooseDecoration(
            textStyle: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        Container(
          height: 120,
          color: Colors.purple,
        ),
        Container(
          height: 120,
          color: Colors.pink,
        ),
        Container(
          height: 120,
          color: Colors.deepOrange,
        ),
        Container(
          height: 120,
          color: Colors.teal,
        ),
        Container(
          height: 120,
          color: Colors.cyan,
        ),
      ],
    );
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
    ];
  }

  Widget _buildPinInputTextFieldExample() {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: ListView(
        children: <Widget>[
          ..._buildConfigWidget(),
          PinInputTextField(
            pinLength: _pinLength,
            decoration: _pinDecoration,
            controller: _pinEditingController,
            textInputAction: TextInputAction.go,
            enabled: _enable,
            onSubmit: (pin) {
              debugPrint('submit pin:$pin');
            },
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
          PinInputTextFormField(
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
            onSaved: (pin) {
              debugPrint('submit pin:$pin');
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
