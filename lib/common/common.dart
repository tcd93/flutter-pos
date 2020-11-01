/// A helper class
class Common {
  /// Clone a [Map] object.
  /// `creator` is the method to create _new_ instance of `V`
  static Map<K, V> cloneMap<K, V>(Map<K, V> map, V Function(K, V) creator) =>
      {for (var key in map.keys) key: creator(key, map[key])};
}
