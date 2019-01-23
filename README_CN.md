[![pub package](https://img.shields.io/pub/v/pin_input_text_field.svg)](https://pub.dartlang.org/packages/pin_input_text_field) 

# pin_input_text_field

PinInputTextField是一个Flutter平台上用来展示不同样式的验证码，简单好用！

## 例子🌰

### 装饰器

UnderlineDecoration
![](https://user-gold-cdn.xitu.io/2018/12/31/1680354b3f04d824?w=808&h=1696&f=gif&s=2209887)


BoxLooseDecoration
![](https://user-gold-cdn.xitu.io/2018/12/31/168035580f8f7a2e?w=804&h=1696&f=gif&s=3533729)


BoxTightDecoration
![](https://user-gold-cdn.xitu.io/2018/12/31/168035580f8f7a2e?w=804&h=1696&f=gif&s=3533729)

### 密码模式

```
/// 是否需要替换[obscureText]开启密码模式.
final bool isTextObscure;
/// 当[isTextObscure]开启时，替换验证码的字符串，长度必须为1.
final String obscureText;
```

## 安装
从[pub](https://pub.dartlang.org/packages/pin_input_text_field)安装最新版.

## 使用

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
                pinLength: 4,                                   /// 验证码长度，默认为4.
                decoration: _pinDecoration,                     /// 外观装饰器，用于控制文字和边框.
                pinEditingController: _pinEditingController,    /// 观察以及设置值.
                autoFocus: true,    
                onSubmit: (pin) {
                    /// 处理用户点击完成.
                    debugPrint('submit pin:$pin');
                },
              ),
```
