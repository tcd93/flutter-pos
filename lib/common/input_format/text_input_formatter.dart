import 'dart:math';
import 'package:flutter/services.dart';

import '../../common/common.dart';

/// Formatter for percentage-type number [double]; auto set to 100.0 if exceeds 100.0.
class NumberEL100Formatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final number = double.tryParse(newValue.text);
    return number == null
        ? newValue.copyWith(text: '')
        : number > 100
            ? newValue.copyWith(text: '100')
            : newValue;
  }
}

String trimRight(String from, String pattern) {
  if (from.isEmpty || pattern.isEmpty || pattern.length > from.length) return from;

  while (from.endsWith(pattern)) {
    from = from.substring(0, from.length - pattern.length);
  }
  return from;
}

/// Formatter for money-type text, the separator ("," or ".") is Locale dependant.
/// VN use dot separator, for example: "1.000" is a valid to represent one-thousand vnd;
/// US uses comma separator.
class MoneyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    // invalid signed number
    if (newValue.text.contains('-', 1)) {
      return oldValue;
    }
    if (newValue.text == '-') {
      return newValue;
    }
    final oldNumber = Money.unformat(oldValue.text);
    final newNumber = Money.unformat(newValue.text);

    // in case non-number is removed (like deleting comma, dot... from oldValue),
    // display the new number without any format
    if (oldNumber == newNumber) {
      return newValue;
    }
    final newString = Money.format(newNumber);
    final adjustment = (newString.length - newValue.text.length).sign;

    return newValue.copyWith(
      text: newString,
      selection: TextSelection.fromPosition(
        TextPosition(
          offset: min(newString.length, newValue.selection.baseOffset + adjustment),
        ),
      ),
    );
  }
}
