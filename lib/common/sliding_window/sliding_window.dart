class SlidingWindow<T> extends Iterable<T> {
  @override
  final int length;
  List<T> lst;

  SlidingWindow(this.length, List<T> list)
      : assert(length > 0),
        assert(length == list.length),
        lst = list.toList(growable: true);

  /// slide in from right, remove fist
  T slideRight(T n) {
    var oldState = lst.removeAt(0);
    lst.add(n);
    return oldState;
  }

  /// slide in from left, remove last
  T slideLeft(T n) {
    var lastState = lst.removeAt(length - 1);
    lst.insert(0, n);
    return lastState;
  }

  T get current => lst.elementAt(length - 1);

  @override
  Iterator<T> get iterator => lst.iterator;
}
