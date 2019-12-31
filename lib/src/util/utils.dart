extension NumListExtension<T extends num> on Iterable<T> {
  /// Return the sum of the list even the list is empty.
  T sumList() {
    if (T == int) {
      var sum = 0;
      this.forEach((n) => sum += n);
      return sum as T;
    } else if (T == double) {
      var sum = 0.0;
      this.forEach((n) => sum += n);
      return sum as T;
    }
    throw AssertionError("not support type:${T.runtimeType}");
  }
}
