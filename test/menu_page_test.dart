import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/provider/src.dart';

void main() {
  late OrderSupplier testModel;

  setUp(() {
    testModel = OrderSupplier()
      ..putIfAbsent(Dish('test1', 100)).quantity = 5
      ..putIfAbsent(Dish('test2', 200)).quantity = 0
      ..putIfAbsent(Dish('test3', 300)).quantity = 15
      ..putIfAbsent(Dish('test4', 400)).quantity = 10;
  });

  group('Not confirmed: ', () {
    setUp(() => testModel.revert());
    test('Should revert all items to 0', () {
      expect(testModel.activeLineItems.length, 0);
      expect(testModel.totalMenuItemQuantity, 0);
      expect(testModel.totalPricePreDiscount, 0);
    });
  });

  group('Confirmed: ', () {
    setUp(() => testModel.memorizePreviousState());
    test('Should keep states of all items', () {
      testModel.revert();

      expect(testModel.activeLineItems.length, 3);
      expect(testModel.totalMenuItemQuantity, 30);
      expect(testModel.totalPricePreDiscount, 9000);
    });

    test('Should keep previous state when add to current state, then revert', () {
      testModel.putIfAbsent(Dish('test1', 100)).quantity++;
      testModel.putIfAbsent(Dish('test5', 500)).quantity = 1; // new item here

      testModel.revert();

      expect(testModel.totalMenuItemQuantity, 30);
      expect(testModel.activeLineItems.length, 3);
      expect(testModel.totalPricePreDiscount, 9000);
    });
  });
}
