import 'package:flutter_test/flutter_test.dart';

import 'package:hembo/models/table.dart';

void main() {
  TableModel _testModel;

  // TODO: make MENU injectable
  setUp(() {
    _testModel = TableModel(null, 0)
      ..lineItem(1).quantity = 5
      ..lineItem(2).quantity = 0
      ..lineItem(3).quantity = 15
      ..lineItem(4).quantity = 10;
  });

  group('Not confirmed: ', () {
    setUp(() => _testModel.revert());
    test('Should revert all items to 0', () {
      expect(_testModel.lineItems.length, 0);
      expect(_testModel.totalMenuItemQuantity, 0);
      expect(_testModel.totalPrice, 0);
    });
  });

  group('Confirmed: ', () {
    setUp(() => _testModel.memorizePreviousState());
    test('Should keep states of all items', () {
      _testModel.revert();

      expect(_testModel.lineItems.length, 3);
      expect(_testModel.totalMenuItemQuantity, 30);
      expect(_testModel.totalPrice, 1200000);
    });

    test('Should keep previous state when add to current state, then revert', () {
      _testModel.lineItem(1).quantity++;
      _testModel.lineItem(5).quantity = 1; // new item here

      _testModel.revert();

      expect(_testModel.totalMenuItemQuantity, 30);
      expect(_testModel.lineItems.length, 3);
      expect(_testModel.totalPrice, 1200000);
    });
  });
}
