import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/common/common.dart';

void main() {
  final mFormatter = MoneyFormatter();
  test('Should display non-formatted number', () {
    // initial txtbox value, the user click at 3rd index
    final oldVal = TextEditingValue(
      text: '1,234',
      selection: TextSelection(baseOffset: 2, extentOffset: 2),
    );
    // now the user press backspace, intent to delete the comma
    final newVal = TextEditingValue(
      text: '1234',
      selection: TextSelection(baseOffset: 1, extentOffset: 1),
    );

    final expected = TextEditingValue(
      text: '1234',
      selection: TextSelection(baseOffset: 1, extentOffset: 1),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should display non-formatted number [signed]', () {
    // initial txtbox value, the user click at 3rd index
    final oldVal = TextEditingValue(
      text: '-1,234',
      selection: TextSelection(baseOffset: 3, extentOffset: 3),
    );
    // now the user press backspace, intent to delete the comma
    final newVal = TextEditingValue(
      text: '-1234',
      selection: TextSelection(baseOffset: 2, extentOffset: 2),
    );

    final expected = TextEditingValue(
      text: '-1234',
      selection: TextSelection(baseOffset: 2, extentOffset: 2),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should delete digits to blank box', () {
    final oldVal = TextEditingValue(
      text: '1',
      selection: TextSelection(baseOffset: 1, extentOffset: 1),
    );
    final newVal = TextEditingValue(
      text: '',
      selection: TextSelection(baseOffset: 0, extentOffset: 0),
    );

    final expected = TextEditingValue(
      text: '',
      selection: TextSelection(baseOffset: 0, extentOffset: 0),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should place cursor correctly after adding comma to 1000', () {
    final oldVal = TextEditingValue(
      text: '100',
      selection: TextSelection(baseOffset: 3, extentOffset: 3),
    );
    final newVal = TextEditingValue(
      text: '1000',
      selection: TextSelection(baseOffset: 4, extentOffset: 4),
    );

    final expected = TextEditingValue(
      text: '1,000',
      selection: TextSelection(baseOffset: 5, extentOffset: 5),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should place cursor correctly after adding comma to -1000', () {
    final oldVal = TextEditingValue(
      text: '-100',
      selection: TextSelection(baseOffset: 4, extentOffset: 4),
    );
    final newVal = TextEditingValue(
      text: '-1000',
      selection: TextSelection(baseOffset: 5, extentOffset: 5),
    );

    final expected = TextEditingValue(
      text: '-1,000',
      selection: TextSelection(baseOffset: 6, extentOffset: 6),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should add dots', () {
    final oldVal = TextEditingValue(
      text: '105',
      selection: TextSelection(baseOffset: 2, extentOffset: 2),
    );
    final newVal = TextEditingValue(
      text: '10.5',
      selection: TextSelection(baseOffset: 3, extentOffset: 3),
    );

    final expected = TextEditingValue(
      text: '10.5',
      selection: TextSelection(baseOffset: 3, extentOffset: 3),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should add dots (2)', () {
    final oldVal = TextEditingValue(
      text: '1,050',
      selection: TextSelection(baseOffset: 4, extentOffset: 4),
    );
    final newVal = TextEditingValue(
      text: '1,05.0',
      selection: TextSelection(baseOffset: 5, extentOffset: 5),
    );

    final expected = TextEditingValue(
      text: '105',
      selection: TextSelection(baseOffset: 3, extentOffset: 3),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should add dots (3)', () {
    final oldVal = TextEditingValue(
      text: '1,051',
      selection: TextSelection(baseOffset: 4, extentOffset: 4),
    );
    final newVal = TextEditingValue(
      text: '1,05.1',
      selection: TextSelection(baseOffset: 5, extentOffset: 5),
    );

    final expected = TextEditingValue(
      text: '105.1',
      selection: TextSelection(baseOffset: 4, extentOffset: 4),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should add dots (4)', () {
    final oldVal = TextEditingValue(
      text: '1,051',
      selection: TextSelection(baseOffset: 5, extentOffset: 5),
    );
    final newVal = TextEditingValue(
      text: '1,051.',
      selection: TextSelection(baseOffset: 6, extentOffset: 6),
    );

    final expected = TextEditingValue(
      text: '1,051.',
      selection: TextSelection(baseOffset: 6, extentOffset: 6),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should display sign', () {
    final oldVal = TextEditingValue(
      text: '',
      selection: TextSelection(baseOffset: 0, extentOffset: 0),
    );
    final newVal = TextEditingValue(
      text: '-',
      selection: TextSelection(baseOffset: 1, extentOffset: 1),
    );

    final expected = TextEditingValue(
      text: '-',
      selection: TextSelection(baseOffset: 1, extentOffset: 1),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should display -1', () {
    final oldVal = TextEditingValue(
      text: '-',
      selection: TextSelection(baseOffset: 1, extentOffset: 1),
    );
    final newVal = TextEditingValue(
      text: '-1',
      selection: TextSelection(baseOffset: 2, extentOffset: 2),
    );

    final expected = TextEditingValue(
      text: '-1',
      selection: TextSelection(baseOffset: 2, extentOffset: 2),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });
}
