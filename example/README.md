# example/main.dart
```

/// more examples see https://github.com/TinoGuo/pin_input_text_field/tree/master/example
import 'package:pin_input_text_field/pin_input_text_field.dart';

PinInputTextField(
                pinLength: 4,
                decoration: _pinDecoration,
                pinEditingController: _pinEditingController,
                autoFocus: true,
                textInputAction: TextInputAction.go,
                onSubmit: (pin) {
                  debugPrint('submit pin:$pin');
                },
              )
```


