extension NumListExtension<T extends num> on Iterable<T> {
  /// Return the sum of the list even the list is empty.
  T sumList() {
    var sum = 0.0 as T;
    this.forEach((n) => sum += n);
    return sum;
  }
}
