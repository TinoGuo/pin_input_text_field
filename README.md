[![pub package](https://img.shields.io/pub/v/pin_input_text_field.svg)](https://pub.dartlang.org/packages/pin_input_text_field)

# pin_input_text_field

[中文版点我](./README_CN.md)
PinInputTextField is a TextField widget to help display different style pin.

## Example

### Decoration

UnderlineDecoration
![](https://user-gold-cdn.xitu.io/2018/12/31/1680354b3f04d824?w=808&h=1696&f=gif&s=2209887)


BoxLooseDecoration
![](https://user-gold-cdn.xitu.io/2018/12/31/168035580f8f7a2e?w=804&h=1696&f=gif&s=3533729)


BoxTightDecoration
![](https://user-gold-cdn.xitu.io/2018/12/31/168035580f8f7a2e?w=804&h=1696&f=gif&s=3533729)

### ObscureStyle

```
/// Determine whether replace [obscureText] with number.
final bool isTextObscure;
/// The display text when [isTextObscure] is true
final String obscureText;
```

## Installing
Install the latest version from [pub](https://pub.dartlang.org/packages/pin_input_text_field).

## Usage

```
PinEditingController _pinEditingController = PinEditingController();
PinDecoration _pinDecoration = UnderlineDecoration(textStyle: _textStyle);
static final TextStyle _textStyle = TextStyle(
  color: Colors.black,
  fontSize: 24,
 );
bool _obscureEnable = false;
PinEntryType _pinEntryType = PinEntryType.underline;

PinInputTextField(
                pinLength: 4,                                   /// The length of the pin.
                decoration: _pinDecoration,                     /// Control the display of text and border.
                pinEditingController: _pinEditingController,    /// Control pin and observe pin.
                autoFocus: true,    
                onSubmit: (pin) {
                    /// Add action to handle submit.
                    debugPrint('submit pin:$pin');
                },
              ),
```
