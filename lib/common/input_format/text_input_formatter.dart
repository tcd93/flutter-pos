import 'package:flutter/material.dart';
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

/// Formatter for money-type text, the separator ("," or ".") is Locale dependant.
/// VN use dot separator, for example: "1.000" is a valid to represent one-thousand vnd;
/// US uses comma separator.
///
/// TODO fix clunkiness
class MoneyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final number = Money.unformat(newValue.text);
    return newValue.copyWith(
      text: Money.format(number),
      selection: TextSelection.collapsed(offset: Money.format(number).length),
    );
  }
}
