/// A helper class
class Common {
  /// Clone a [Map] object.
  /// `creator` is the method to create _new_ instance of `V`
  static Map<K, V> cloneMap<K, V>(Map<K, V> map, V Function(K, V) creator) =>
      {for (var key in map.keys) key: creator(key, map[key])};

  /// Create a string in the form of `YYYYMMDD`
  static String extractYYYYMMDD(DateTime dateTime) =>
      '${dateTime.year.toString()}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}';

  /// Create a string in the form of `YYYY/MM/DD`
  static String extractYYYYMMDD2(DateTime dateTime) =>
      '${dateTime.year.toString()}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';

  /// Create a string in the form of `YYYY-MM-DD HH24:MM`
  static String extractYYYYMMDD3(DateTime dateTime) =>
      '${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
