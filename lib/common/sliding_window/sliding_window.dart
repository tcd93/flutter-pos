class SlidingWindow<T> extends Iterable<T> {
  @override
  final int length;
  final List<T> _lst;

  SlidingWindow(List<T> list)
      : assert(list.isNotEmpty),
        length = list.length,
        _lst = list.toList(growable: true);

  /// slide in from right, remove fist
  slideRight(T n) {
    _lst.removeAt(0);
    _lst.add(n);
  }

  /// slide in from left, remove last
  slideLeft(T n) {
    _lst.removeAt(length - 1);
    _lst.insert(0, n);
  }

  replaceFirst(T n) {
    _lst.first = n;
  }

  @override
  Iterator<T> get iterator => _lst.iterator;
}
