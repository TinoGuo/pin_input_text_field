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
    this.obscureText: '•',
  })  :

        /// Not allowed empty string and multiline string.
        assert(obscureText.length > 0),
        assert(obscureText.indexOf(_wrapLine) == -1);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObscureStyle &&
          runtimeType == other.runtimeType &&
          isTextObscure == other.isTextObscure &&
          obscureText == other.obscureText;

  @override
  int get hashCode => isTextObscure.hashCode ^ obscureText.hashCode;

  @override
  String toString() {
    return 'ObscureStyle{isTextObscure: $isTextObscure, obscureText: $obscureText}';
  }
}
