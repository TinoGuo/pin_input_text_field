## [2.0.0] - 2019/08/12
* **Update: parameter `pinEditingController` renamed to `controller`.**
* **Remove: remove the `PinEditingController` class, just simply use `TextEditingController`.**
* Fix: support dynamically changing of length & controller.
* New: allow custom `key`.
* **Notice: Please set the selection when you set the text programmatically.** 

## [1.0.1] - 2019/06/23
* Fix: fix fatal error

## [1.0.0] - 2019/06/23
* Update: obscure text support emoji now.

## [0.4.0] - 2019/05/23
* New: add 'enable' to control pin input.

## [0.3.1] - 2019/05/12
* Update: complete example `readme.md` and `pubspec.yaml`.

## [0.3.0] - 2019/04/09

* New: no need to correct user's input.
* New: align actual text in center to make popup window more natural.
* New: obscure mode is always on now.
* New: add `textInputAction` to control TextInputAction.

### Breaking Change
- `PinEditingController` constructor must provide pinLength.
- `PinEditingController` constructor provide new field `autoDispose` to simplify dispose.
- `PinTextField` constructor remove `width` and `height` field, if you want customize size of the `PinInputTextField`, you can wrap a `Container` widget.

## [0.2.1] - 2019/01/20

* change default color of underlineDecoration from Colors.Black to Colors.cyan.
* add more detail example. 

## [0.2.0] - 2019/01/20

* add keyboardType & inputFormatters control.
* add autoFocus & focusNode control.
* add controller to assign pin.

## [0.1.1] - 2019/01/09

* change license from MIT to Apache.

## [0.1.0] - 2019/01/09

* add comment to help understand source code.
* add obscure style to be more customize.
* add onPinChanged to observe the text changed.
* add solidColor to set background color in BoxLooseDecoration & BoxTightDecoration.
* add enteredColor for UnderlineDecoration&BoxLooseDecoration.
* remove const default variable in PinInputTextField.
* fix wrong place in painting

## [0.0.1] - 2018/12/24.

* first commit.