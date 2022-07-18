import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/database_factory.dart';
import 'package:posapp/provider/src.dart';
import 'package:posapp/storage_engines/connection_interface.dart';

void main() {
  DatabaseConnectionInterface sqlite = DatabaseFactory().create('sqlite');
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
    late RIDRepository<Order> repo;

    setUpAll(() {
      repo = DatabaseFactory().createRIDRepository<Order>(sqlite);
    });

    setUp(() async {
      await sqlite.truncate();
    });

    test('Should insert a row', () async {
      await repo.insert(order);

      final result = (await repo.get(checkOutTime));
      expect(result, isNotEmpty);
      expect(result.length, 1);
      expect(result[0].toJson(), {...order.toJson(), 'ID': 1});
    });

    test('Should insert 2 rows', () async {
      await repo.insert(order);
      await repo.insert(order2);

      final result = (await repo.get(checkOutTime));
      expect(result, isNotEmpty);
      expect(result.length, 2);
      expect(result[0].toJson(), {...order.toJson(), 'ID': 1});
      expect(result[1].toJson(), {...order2.toJson(), 'ID': 2});
    });

    test('Should insert 3 rows', () async {
      await repo.insert(order);
      await repo.insert(order2);
      await repo.insert(order3);

      final result = (await repo.get(checkOutTime, checkOutTime3));
      expect(result, isNotEmpty);
      expect(result.length, 3);
      expect(result[2].toJson(), {...order3.toJson(), 'ID': 3});
    });
  });

  group('Delete', () {
    late RIDRepository<Order> repo;

    setUpAll(() {
      repo = DatabaseFactory().createRIDRepository<Order>(sqlite);
    });

    setUp(() async {
      await sqlite.truncate();
    });

    test('Should soft-delete a row', () async {
      final or = await repo.insert(order); // with ID
      await repo.delete(or);

      final result = (await repo.get(checkOutTime));
      expect(result.length, 1);
      expect(result[0].toJson(), Order.create(fromBase: or, isDeleted: true).toJson());
    });
  });

  group('Node Op', () {
    late RIUDRepository<Node> repo;

    setUpAll(() {
      repo = DatabaseFactory().createRIUDRepository<Node>(sqlite);
    });

    setUp(() async {
      await sqlite.truncate();
    });
    test('Setting coords of a table', () async {
      var node = await repo.insert(Node(page: 0));
      expect(node.id, 1);

      node.x = 100;
      node.y = 155.5;
      await repo.update(node);
      var newNode = await repo.get(node.id);
      expect(newNode.first.x, 100);
      expect(newNode.first.y, 155.5);

      node.x = 10;
      node.y = 15.5;
      await repo.update(node);
      newNode = await repo.get(node.id);
      expect(newNode.first.x, 10);
      expect(newNode.first.y, 15.5);
    });
  });
}
