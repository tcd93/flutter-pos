import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/provider/src.dart';
import 'package:posapp/storage_engines/sqlite.dart';

void main() {
  SQLite sqlite = SQLite('test');
  final checkOutTime = DateTime(2017, 9, 7, 17, 30);
  final checkOutTime2 = DateTime(2017, 9, 7, 19, 30);
  final checkOutTime3 = DateTime(2017, 9, 8, 20, 30);
  final Order order = Order.create(
    tableID: 0,
    checkoutTime: checkOutTime,
    lineItems: LineItemList([
      LineItem(
        associatedDish: Dish('Test Dish 0', 5000),
        quantity: 1,
      ),
      LineItem(
        associatedDish: Dish('Test Dish 1', 6000),
        quantity: 2,
      ),
    ]),
  );
  final Order order2 = Order.create(
    tableID: 0,
    checkoutTime: checkOutTime2,
    lineItems: LineItemList([
      LineItem(
        associatedDish: Dish('Test Dish 3', 5000),
        quantity: 1,
      ),
      LineItem(
        associatedDish: Dish('Test Dish 4', 6000),
        quantity: 2,
      ),
    ]),
  );
  final Order order3 = Order.create(
    tableID: 0,
    checkoutTime: checkOutTime3,
    lineItems: LineItemList([
      LineItem(
        associatedDish: Dish('Test Dish 1', 6000),
        quantity: 1,
      ),
      LineItem(
        associatedDish: Dish('Test Dish 4', 6000),
        quantity: 2,
      ),
    ]),
  );

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized(); // must have this line for sqlite to work
    expect(await sqlite.open(), true);
  });

  tearDownAll(() async {
    await sqlite.destroy();
    await sqlite.close();
  });

  group('Insert', () {
    setUp(() async {
      await sqlite.truncate();
    });

    test('Should insert a row', () async {
      await sqlite.insert(order);

      final result = (await sqlite.get(checkOutTime));
      expect(result, isNotEmpty);
      expect(result.length, 1);
      expect(result[0].toJson(), {...order.toJson(), 'orderID': 1});
    });

    test('Should insert 2 rows', () async {
      await sqlite.insert(order);
      await sqlite.insert(order2);

      final result = (await sqlite.get(checkOutTime));
      expect(result, isNotEmpty);
      expect(result.length, 2);
      expect(result[0].toJson(), {...order.toJson(), 'orderID': 1});
      expect(result[1].toJson(), {...order2.toJson(), 'orderID': 2});
    });

    test('Should insert 3 rows', () async {
      await sqlite.insert(order);
      await sqlite.insert(order2);
      await sqlite.insert(order3);

      final result = (await sqlite.getRange(checkOutTime, checkOutTime3));
      expect(result, isNotEmpty);
      expect(result.length, 3);
      expect(result[2].toJson(), {...order3.toJson(), 'orderID': 3});
    });
  });

  group('Delete', () {
    setUp(() async {
      await sqlite.truncate();
    });

    test('Should soft-delete a row', () async {
      await sqlite.insert(order);
      expect(await sqlite.delete(checkOutTime, 1), 1);

      final result = (await sqlite.get(checkOutTime));
      expect(result.length, 1);
      expect(result[0].toJson(), {...order.toJson(), 'orderID': 1, 'isDeleted': true});
    });
  });

  group('Node Op', () {
    setUp(() async {
      await sqlite.truncate();
    });
    test('Setting coords of a table', () async {
      var newID = await sqlite.addTable();
      expect(newID, 1);

      await sqlite.setCoordinate(newID, 100, 155.5);
      expect(await sqlite.getX(1), 100);
      expect(await sqlite.getY(1), 155.5);

      await sqlite.setCoordinate(newID, 10, 15.5);
      expect(await sqlite.getX(1), 10);
      expect(await sqlite.getY(1), 15.5);
    });
  });
}
