/// A helper class
class Common {
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
