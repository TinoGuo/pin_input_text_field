## [4.5.1] - 2023/06/25
* Update dart sdk constraints

## [4.5.0] - 2023/02/11
* New:
  * Support cursor with orientation and offset
  * Add TextFieldTapRegion and callback
**Breaking Change** 
- No more support below 3.7.0
- No default decoration provided in PinInputTextField
- PinDecoration is not const

## [4.4.1] - 2023/02/19
* Revert parameter changes 4.2.0 between 4.4.0 inclusively, this version will be the last version to support below 3.7.0

## [4.4.0] - 2023/02/07
* Revert remove toolbarOptions

## [4.3.0] - 2023/02/05
* Adapt to new flutter version and rename deprecated fields
* Upgrade lint version

## [4.2.0] - 2022/09/10
* Fixed Cursor overriding HintText [#75](https://github.com/TinoGuo/pin_input_text_field/pull/75)

## [4.1.2] - 2022/03/19
* Correctly remove&add FocusNode listener [#73](https://github.com/TinoGuo/pin_input_text_field/issues/73)

## [4.1.1] - 2021/09/25
* Apply Analyzer and lint

## [4.1.0] - 2021/05/22
* Bump Dart to 2.13

## [4.0.0] - 2021/03/14
* Migrate to Null Safety

## [3.3.1] - 2021/02/07
* New : `StrokeCap` for UnderlineDecoration.

## [3.3.0] - 2020/12/30
* Update: `inputFormatter` replace with `inputFormatters` to keep same as TextField.
* Remove: Unused assert, Default inputFormatters.

## [3.2.0] - 2020/12/29
* New: Cursor display #56
* Hint: Cursor would override hintText is enabled.

## [3.1.2] - 2020/12/22
* `autofillHints` Support #51

## [3.1.1] - 2020/09/08
* Fix: [#46](https://github.com/TinoGuo/pin_input_text_field/issues/46)

## [3.1.0] - 2020/09/05
* **Breaking Change, the `color` is renamed to `colorBuilder` as well as enterColor, the `solidColor` is renamed to `bgColorBuilder`**
* New: Support stroke color and background color change when enter new pin
* Fix: InnerRadius overlap the stroke
* Fix: Some scenarios not update the paint

## [3.0.7] - 2020/08/30
* Fix: All minimize font size is the double.minPositive

## [3.0.6] - 2020/08/30
* Fix: Disabled inputDecoration theme in widget
* Fix: add minimize font size 1 in web

## [3.0.5] - 2020/08/22
* Fix: the interaction issue in Android Platform

## [3.0.4] - 2020/07/04
* New: support `solidColor` in `underlineDecoration`

## [3.0.3] - 2020/06/14
* New: support copy-past pin
* New: support control `autocorrect`
* Update: Default obscureText `•`

## [3.0.2] - 2020/06/01
* New: support `TextCapitalization`

## [3.0.1] - 2019/12/31
* Update: optimise directory

## [3.0.0] - 2019/12/30
* Update: minimum sdk version - 2.7
* New: add built-in `CircleDecoration` 
* New: support customized decoration, you can draw anything you want from now!

## [2.1.0] - 2019/10/24
* New: add `hintText` for all `PinDecoration` .
* New: custom gapSpace support for `UnderlineDecoration` and `BoxLooseDecoration`.

## [2.0.3] - 2019/10/16
* New: add `onChanged` parameter.
* Fix: fix null controller will not work in `PinInputTextFormField`.

## [2.0.2] - 2019/10/08
* Fix: fix missing first build initial value. Thanks to [daniel-v](https://github.com/daniel-v)

## [2.0.1] - 2019/09/27
* New: add 'PinInputTextFormField' to support form validate. Thanks to [rajajain08](https://github.com/rajajain08).

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