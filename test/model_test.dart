import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/database_factory.dart';
import 'package:posapp/provider/src.dart';
import 'package:posapp/storage_engines/connection_interface.dart';

void main() {
  late Supplier mockTracker;
  const _db = String.fromEnvironment('database', defaultValue: 'local-storage');
  var mockTable = TableModel();
  var storage = DatabaseFactory().create(_db, 'test', {}, 'model_test');
  late RIRepository<Order> repo;

  setUpAll(() async {
    await storage.open();
    repo = DatabaseFactory().createRIRepository<Order>(storage);
    mockTracker = Supplier();
  });

  tearDownAll(() async {
    await storage.destroy();
    await storage.close();
    if (_db == 'local-storage') {
      File('test/model_test').deleteSync();
    }
  });

  setUp(() async {
    await storage.truncate();
    mockTable = TableModel()
      ..putIfAbsent(Dish('test1', 100)).quantity = 5
      ..putIfAbsent(Dish('test5', 500)).quantity = 10
      ..putIfAbsent(Dish('test3', 300)).quantity = 15;
    mockTracker = Supplier(
      mockModels: [mockTable],
    );
  });

  test('mockTable total quantity should be 30', () {
    expect(mockTable.totalMenuItemQuantity, 30);
  });

  test('Table should go back to blank state after checkout', () async {
    await mockTracker.checkout(mockTable);
    await mockTable.printClear();
    expect(mockTable.totalMenuItemQuantity, 0);
    expect(mockTable.status, TableStatus.empty);
  });

  test('Order should persist to storage after checkout', () async {
    await mockTracker.checkout(mockTable, repo, DateTime.parse('20200201 11:00:00'));
    await mockTable.printClear();
    var items = await repo.get(DateTime.parse('20200201 11:00:00'));
    expect(items, isNotNull);
    expect(items[0].checkoutTime, DateTime.parse('20200201 11:00:00'));
    expect(items[0].id, 1);
    expect(() => items[1], throwsRangeError);
  });

  test('OrderID increase by 1 after first order', () async {
    await mockTracker.checkout(mockTable, repo, DateTime.parse('20200201 11:00:00'));
    await mockTable.printClear();

    // create new order
    final mockTable2 = TableModel()..putIfAbsent(Dish('test1', 100)).quantity = 5;

    await mockTracker.checkout(mockTable2, repo, DateTime.parse('20200201 13:00:00'));
    await mockTable2.printClear();

    var items = await repo.get(DateTime.parse('20200201 13:00:00'));
    expect(items.length, 2);
    expect(items[0].id, 1);
    expect(items[1].id, 2);
  });
}
