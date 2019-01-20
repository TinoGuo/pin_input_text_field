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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PinEditingController _pinEditingController = PinEditingController();
  PinDecoration _pinDecoration = UnderlineDecoration(textStyle: _textStyle);
  static final TextStyle _textStyle = TextStyle(
    color: Colors.black,
    fontSize: 24,
  );
  bool _obscureEnable = false;
  PinEntryType _pinEntryType = PinEntryType.underline;

  void _setPinValue() {
    _pinEditingController.text = "1234";
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
            obscureStyle: ObscureStyle(
              isTextObscure: _obscureEnable,
            ),
          );
        });
        break;
      case PinEntryType.boxTight:
        setState(() {
          _pinDecoration = BoxTightDecoration(
            textStyle: _textStyle,
            obscureStyle: ObscureStyle(
              isTextObscure: _obscureEnable,
            ),
          );
        });
        break;
      case PinEntryType.boxLoose:
        setState(() {
          _pinDecoration = BoxLooseDecoration(
            textStyle: _textStyle,
            obscureStyle: ObscureStyle(
              isTextObscure: _obscureEnable,
            ),
          );
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 32),
              child: PinInputTextField(
                pinLength: 4,
                decoration: _pinDecoration,
                pinEditingController: _pinEditingController,
                autoFocus: true,
                onSubmit: (pin) {
                  debugPrint('submit pin:$pin');
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _setPinValue,
        tooltip: 'setPinValue',
        child: Icon(Icons.border_color),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
