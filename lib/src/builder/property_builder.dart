/// This class is abstract for query index of generic type.
abstract class PropertyIndexBuilder<T> {
  const PropertyIndexBuilder();

  // query the index of color
  T indexProperty(int index);

  void notifyChange(String enteredPin) {}
}
