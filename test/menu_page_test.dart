import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/provider/src.dart';

void main() {
  var _testModel = TableModel(-1);

  setUp(() {
    _testModel = TableModel(0)
      ..putIfAbsent(Dish(1, 'test1', 100)).quantity = 5
      ..putIfAbsent(Dish(2, 'test2', 200)).quantity = 0
      ..putIfAbsent(Dish(3, 'test3', 300)).quantity = 15
      ..putIfAbsent(Dish(4, 'test4', 400)).quantity = 10;
  });

  group('Not confirmed: ', () {
    setUp(() => _testModel.revert());
    test('Should revert all items to 0', () {
      expect(_testModel.lineItems.length, 0);
      expect(_testModel.totalMenuItemQuantity, 0);
      expect(_testModel.totalPricePreDiscount, 0);
    });
  });

  group('Confirmed: ', () {
    setUp(() => _testModel.memorizePreviousState());
    test('Should keep states of all items', () {
      _testModel.revert();

      expect(_testModel.lineItems.length, 3);
      expect(_testModel.totalMenuItemQuantity, 30);
      expect(_testModel.totalPricePreDiscount, 9000);
    });

    test('Should keep previous state when add to current state, then revert', () {
      _testModel.putIfAbsent(Dish(1, 'test1', 100)).quantity++;
      _testModel.putIfAbsent(Dish(5, 'test5', 500)).quantity = 1; // new item here

      _testModel.revert();

      expect(_testModel.totalMenuItemQuantity, 30);
      expect(_testModel.lineItems.length, 3);
      expect(_testModel.totalPricePreDiscount, 9000);
    });
  });
}
