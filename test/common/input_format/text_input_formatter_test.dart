import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/common/common.dart';

void main() {
  final mFormatter = MoneyFormatter();
  test('Should display non-formatted number', () {
    // initial txtbox value, the user click at 3rd index
    const oldVal = TextEditingValue(
      text: '1,234',
      selection: TextSelection(baseOffset: 2, extentOffset: 2),
    );
    // now the user press backspace, intent to delete the comma
    const newVal = TextEditingValue(
      text: '1234',
      selection: TextSelection(baseOffset: 1, extentOffset: 1),
    );

    const expected = TextEditingValue(
      text: '1234',
      selection: TextSelection(baseOffset: 1, extentOffset: 1),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should display non-formatted number [signed]', () {
    // initial txtbox value, the user click at 3rd index
    const oldVal = TextEditingValue(
      text: '-1,234',
      selection: TextSelection(baseOffset: 3, extentOffset: 3),
    );
    // now the user press backspace, intent to delete the comma
    const newVal = TextEditingValue(
      text: '-1234',
      selection: TextSelection(baseOffset: 2, extentOffset: 2),
    );

    const expected = TextEditingValue(
      text: '-1234',
      selection: TextSelection(baseOffset: 2, extentOffset: 2),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should delete digits to blank box', () {
    const oldVal = TextEditingValue(
      text: '1',
      selection: TextSelection(baseOffset: 1, extentOffset: 1),
    );
    const newVal = TextEditingValue(
      text: '',
      selection: TextSelection(baseOffset: 0, extentOffset: 0),
    );

    const expected = TextEditingValue(
      text: '',
      selection: TextSelection(baseOffset: 0, extentOffset: 0),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should place cursor correctly after adding comma to 1000', () {
    const oldVal = TextEditingValue(
      text: '100',
      selection: TextSelection(baseOffset: 3, extentOffset: 3),
    );
    const newVal = TextEditingValue(
      text: '1000',
      selection: TextSelection(baseOffset: 4, extentOffset: 4),
    );

    const expected = TextEditingValue(
      text: '1,000',
      selection: TextSelection(baseOffset: 5, extentOffset: 5),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should place cursor correctly after adding comma to -1000', () {
    const oldVal = TextEditingValue(
      text: '-100',
      selection: TextSelection(baseOffset: 4, extentOffset: 4),
    );
    const newVal = TextEditingValue(
      text: '-1000',
      selection: TextSelection(baseOffset: 5, extentOffset: 5),
    );

    const expected = TextEditingValue(
      text: '-1,000',
      selection: TextSelection(baseOffset: 6, extentOffset: 6),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should add dots', () {
    const oldVal = TextEditingValue(
      text: '105',
      selection: TextSelection(baseOffset: 2, extentOffset: 2),
    );
    const newVal = TextEditingValue(
      text: '10.5',
      selection: TextSelection(baseOffset: 3, extentOffset: 3),
    );

    const expected = TextEditingValue(
      text: '10.5',
      selection: TextSelection(baseOffset: 3, extentOffset: 3),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should add dots (2)', () {
    const oldVal = TextEditingValue(
      text: '1,050',
      selection: TextSelection(baseOffset: 4, extentOffset: 4),
    );
    const newVal = TextEditingValue(
      text: '1,05.0',
      selection: TextSelection(baseOffset: 5, extentOffset: 5),
    );

    const expected = TextEditingValue(
      text: '105',
      selection: TextSelection(baseOffset: 3, extentOffset: 3),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should add dots (3)', () {
    const oldVal = TextEditingValue(
      text: '1,051',
      selection: TextSelection(baseOffset: 4, extentOffset: 4),
    );
    const newVal = TextEditingValue(
      text: '1,05.1',
      selection: TextSelection(baseOffset: 5, extentOffset: 5),
    );

    const expected = TextEditingValue(
      text: '105.1',
      selection: TextSelection(baseOffset: 4, extentOffset: 4),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should add dots (4)', () {
    const oldVal = TextEditingValue(
      text: '1,051',
      selection: TextSelection(baseOffset: 5, extentOffset: 5),
    );
    const newVal = TextEditingValue(
      text: '1,051.',
      selection: TextSelection(baseOffset: 6, extentOffset: 6),
    );

    const expected = TextEditingValue(
      text: '1,051.',
      selection: TextSelection(baseOffset: 6, extentOffset: 6),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should display sign', () {
    const oldVal = TextEditingValue(
      text: '',
      selection: TextSelection(baseOffset: 0, extentOffset: 0),
    );
    const newVal = TextEditingValue(
      text: '-',
      selection: TextSelection(baseOffset: 1, extentOffset: 1),
    );

    const expected = TextEditingValue(
      text: '-',
      selection: TextSelection(baseOffset: 1, extentOffset: 1),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });

  test('Should display -1', () {
    const oldVal = TextEditingValue(
      text: '-',
      selection: TextSelection(baseOffset: 1, extentOffset: 1),
    );
    const newVal = TextEditingValue(
      text: '-1',
      selection: TextSelection(baseOffset: 2, extentOffset: 2),
    );

    const expected = TextEditingValue(
      text: '-1',
      selection: TextSelection(baseOffset: 2, extentOffset: 2),
    );
    final actual = mFormatter.formatEditUpdate(oldVal, newVal);

    expect(actual, expected);
  });
}
