# pin_input_text_field

[![pub package](https://img.shields.io/pub/v/pin_input_text_field.svg)](https://pub.dartlang.org/packages/pin_input_text_field) A TextField widget to help display different style pin

## Example

UnderlineDecoration
![](https://user-gold-cdn.xitu.io/2018/12/31/1680354b3f04d824?w=808&h=1696&f=gif&s=2209887)


BoxLooseDecoration
![](https://user-gold-cdn.xitu.io/2018/12/31/168035580f8f7a2e?w=804&h=1696&f=gif&s=3533729)


BoxTightDecoration
![](https://user-gold-cdn.xitu.io/2018/12/31/168035580f8f7a2e?w=804&h=1696&f=gif&s=3533729)

## Installing
Install the latest version from [pub](https://pub.dartlang.org/packages/pin_input_text_field).

## Usage

```
PinInputTextField(
              onSubmit: (pin) {
                //Add submit action.
              },
              pinLength: 6,     // The length of the pin
              decoration: BoxTightDecoration(), // or BoxLooseDecoration, UnderlineDecoration
              width: 300.0,
              height: 48.0,
            );
```
