/// The object determine the obscure display
class ObscureStyle {
  /// The wrap line string.
  static final _wrapLine = '\n';

  /// Determine whether replace [obscureText] with number.
  final bool isTextObscure;

  /// The display text when [isTextObscure] is true, default is '*'
  /// Do Not pass multiline string, it's not a good idea.
  final String obscureText;

  ObscureStyle({
    this.isTextObscure: false,
    this.obscureText: '*',
  })  :

        /// Not allowed empty string and multiline string.
        assert(obscureText.length > 0),
        assert(obscureText.indexOf(_wrapLine) == -1);
}
