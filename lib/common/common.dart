export './draggable_widget/draggable_widget.dart';
export './input_format/text_input_formatter.dart';
export './money_format/money.dart';
export './radial_menu/radial_menu.dart';
export './radial_menu/drawer_item.dart';
export './sliding_window/sliding_window.dart';

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
      '${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${extractTime(dateTime)}';

  /// Create a string in the form of `HH24:MM`
  static String extractTime(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
