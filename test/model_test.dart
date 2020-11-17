import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hembo/database_factory.dart';
import 'package:hembo/models/state/status.dart';

import 'package:hembo/models/supplier.dart';
import 'package:hembo/models/table.dart';
import 'package:hembo/storage_engines/connection_interface.dart';

void main() {
  Supplier mockTracker;
  TableModel mockTable;
  DatabaseConnectionInterface storage;

  setUpAll(() async {
    // must set up like this to "overwrite" existing data
    storage = DatabaseFactory().create('local-storage', 'test', {});
    await storage.open();
  });
  tearDownAll(() {
    storage.close();
    File('test/hembo').deleteSync(); // delete the newly created storage file
  });
  tearDown(() async {
    try {
      await storage.destroy();
    } on Exception {}
  });

  setUp(() async {
    mockTracker = Supplier(
      database: storage,
      modelBuilder: (tracker) => [
        TableModel(tracker, 0)
          ..lineItem(1).quantity = 7
          ..lineItem(1).quantity = 5
          ..lineItem(5).quantity = 10
          ..lineItem(3).quantity = 15,
      ],
    );

    mockTable = mockTracker.getTable(0);
  });

  test('Tracker should be tracking only one table (index 0)', () {
    expect(() => mockTracker.getTable(1), throwsRangeError);
  });

  test('mockTable total quantity should be 30', () {
    expect(mockTable.totalMenuItemQuantity, 30);
  });

  test('Table should go back to blank state after checkout', () async {
    await mockTable.checkout();
    expect(mockTable.totalMenuItemQuantity, 0);
    expect(mockTable.status, TableStatus.empty);
  });

  test('Order should persist to local storage after checkout', () async {
    await mockTable.checkout(DateTime.parse('20200201 11:00:00'));
    var items = DatabaseFactory().create('local-storage').get(DateTime.parse('20200201 11:00:00'));
    expect(items, isNotNull);
    expect(items[0].checkoutTime, DateTime.parse('20200201 11:00:00'));
    expect(items[0].orderID, 0);
    expect(() => items[1], throwsRangeError);
  });

  test('OrderID increase by 1 after first order', () async {
    await mockTable.checkout(DateTime.parse('20200201 11:00:00'));
    // create new order
    mockTable
      ..lineItem(0).quantity = 2
      ..lineItem(1).quantity = 1;
    await mockTable.checkout(DateTime.parse('20200201 13:00:00'));

    var items = DatabaseFactory().create('local-storage').get(DateTime.parse('20200201 13:00:00'));
    expect(items.length, 2);
    expect(items[0].orderID, 0);
    expect(items[1].orderID, 1);
  });
}
