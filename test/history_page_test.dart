import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/database_factory.dart';
import 'package:posapp/provider/src.dart';
import 'package:posapp/screens/history/main.dart';
import 'package:posapp/screens/history/first_tab/order_card.dart';
import 'package:posapp/storage_engines/connection_interface.dart';
import 'package:provider/provider.dart';

final DateTime checkoutTime = DateTime.parse('20201112 13:00:00');

void main() {
  late OrderSupplier supplier;
  late DatabaseConnectionInterface storage;
  late RIDRepository<Order> repo;
  const db = String.fromEnvironment('database', defaultValue: 'local-storage');

  group('Same day report:', () {
    setUpAll(() async {
      storage = DatabaseFactory().create(db, 'test', {}, 'test-group-1');
      await storage.open();
      repo = DatabaseFactory().createRIDRepository<Order>(storage);
      debugPrint('Testing database: $db');
    });
    tearDownAll(() async {
      await storage.destroy();
      await storage.close();
      if (db == 'local-storage') {
        File('test/test-group-1').deleteSync();
      }
      // delete the newly created storage file
    });

    setUp(() async {
      await storage.truncate();

      supplier = OrderSupplier(
        database: repo,
        order: Order.create(
          tableID: 1,
          lineItems: LineItemList([
            LineItem(associatedDish: Dish('Test Dish 1', 120000), quantity: 1),
          ]),
        ),
      );

      await supplier.checkout(checkoutTime);
      await supplier.printClear();
    });

    testWidgets(
      'Should have 1 line in History page, price = 120,000',
      (tester) async {
        expect(supplier.totalMenuItemQuantity, 0); // confirm checked out

        await tester.pumpWidget(MaterialApp(
          builder: (_, __) => ChangeNotifierProvider(
            create: (_) {
              return HistoryOrderSupplier(
                database: repo,
                range: DateTimeRange(start: checkoutTime, end: checkoutTime),
              );
            },
            child: DefaultTabController(length: 2, child: HistoryScreen()),
          ),
        ));

        // this line is very important as HistoryOrderSupplier launches an async operation on
        // creation, runAsync force flutter to execute that operation "for real", otherwise
        // it'll stuck in loading state forever causing timeout in pumpAndSettle.
        // local-storage would work without this line because originally non of its APIs are async
        await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (widget) => widget is OrderCard,
            description: 'Line item number',
          ),
          findsOneWidget,
        );

        expect(
          find.widgetWithText(OrderCard, '120,000'),
          findsOneWidget,
          reason: 'Total price should be 120,000',
        );
      },
    );
  });

  group('Cross day report:', () {
    setUpAll(() async {
      storage = DatabaseFactory().create(db, 'test', {}, 'test-group-2');
      await storage.open();
      repo = DatabaseFactory().createRIDRepository<Order>(storage);
    });

    tearDownAll(() async {
      await storage.destroy();
      await storage.close();
      if (db == 'local-storage') {
        File('test/test-group-2').deleteSync();
      }
    });

    setUp(() async {
      await storage.truncate();

      final order1 = Order.fromJson(const {
        'orderID': 1,
        'checkoutTime': '2020-11-12 01:31:32.840',
        'discountRate': 1.0,
        'lineItems': [
          {'dishID': 0, 'dish': 'Rice Noodles', 'quantity': 1, 'price': 10000.0},
          {'dishID': 1, 'dish': 'Lime Juice', 'quantity': 1, 'price': 20000.0},
          {'dishID': 2, 'dish': 'Vegan Noodle', 'quantity': 1, 'price': 30000.0}
        ]
      });
      final order2 = Order.fromJson(const {
        'orderID': 2,
        'checkoutTime': '2020-11-13 01:31:47.658',
        'discountRate': 1.0,
        'lineItems': [
          {'dishID': 0, 'dish': 'Rice Noodles', 'quantity': 1, 'price': 10000.0},
          {'dishID': 4, 'dish': 'Fried Chicken with Egg', 'quantity': 1, 'price': 50000.0},
          {'dishID': 5, 'dish': 'Kimchi', 'quantity': 1, 'price': 60000.0}
        ]
      });
      final order3 = Order.fromJson(const {
        'orderID': 3,
        'checkoutTime': '2020-11-14 01:31:59.936',
        'discountRate': 1.0,
        'lineItems': [
          {'dishID': 6, 'dish': 'Coffee', 'quantity': 1, 'price': 70000.0}
        ]
      });

      await repo.insert(order1);
      await repo.insert(order2);
      await repo.insert(order3);
    });
    testWidgets(
      'Should have 2 line in History page, price = 180,000',
      (tester) async {
        // but only view by 2 days
        await tester.pumpWidget(MaterialApp(
          builder: (_, __) => ChangeNotifierProvider(
            create: (_) {
              return HistoryOrderSupplier(
                database: repo,
                range: DateTimeRange(
                    start: checkoutTime, end: checkoutTime.add(const Duration(days: 1))),
              );
            },
            child: DefaultTabController(length: 2, child: HistoryScreen()),
          ),
        ));
        // see previous test for note
        await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (widget) => widget is OrderCard,
            description: 'Line item number',
          ),
          findsNWidgets(2),
        );

        expect(
          find.widgetWithText(OrderCard, '120,000'),
          findsOneWidget,
          reason: 'Price of first line item',
        );

        expect(
          find.widgetWithText(OrderCard, '60,000'),
          findsOneWidget,
          reason: 'Price of second line item',
        );
      },
    );
  });

  group('Soft delete order test:', () {
    late Order order1, order2;

    setUpAll(() async {
      storage = DatabaseFactory().create(db, 'test', {}, 'test-group-3');
      await storage.open();
      repo = DatabaseFactory().createRIDRepository<Order>(storage);
    });

    tearDownAll(() async {
      await storage.destroy();
      await storage.close();
      if (db == 'local-storage') {
        File('test/test-group-3').deleteSync();
      }
    });

    setUp(() async {
      await storage.truncate();

      order1 = Order.fromJson(const {
        'orderID': 1,
        'checkoutTime': '2020-11-12 01:31:32.840',
        'discountRate': 1.0,
        'lineItems': [
          {'dishID': 0, 'dish': 'Rice Noodles', 'quantity': 1, 'price': 10000.0},
          {'dishID': 1, 'dish': 'Lime Juice', 'quantity': 1, 'price': 20000.0},
        ],
        'isDeleted': false,
      });
      order2 = Order.fromJson(const {
        'orderID': 2,
        'checkoutTime': '2020-11-12 02:31:32.840',
        'discountRate': 1.0,
        'lineItems': [
          {'dishID': 1, 'dish': 'Lime Juice', 'quantity': 2, 'price': 40000.0},
          {'dishID': 2, 'dish': 'Vegan Noodle', 'quantity': 1, 'price': 30000.0}
        ],
        'isDeleted': false,
      });

      await repo.insert(order1);
      await repo.insert(order2);
    });

    test('Should be able to set isDeleted to true', () async {
      await repo.delete(order2);

      var order = await repo.get(DateTime.parse('2020-11-12'));

      expect(order[0].isDeleted, false);
      expect(order[1].isDeleted, true);
    });
  });

  group('Soft delete order widget test:', () {
    setUpAll(() async {
      storage = DatabaseFactory().create(db, 'test', {}, 'test-group-4');
      await storage.open();
      repo = DatabaseFactory().createRIDRepository<Order>(storage);
    });

    tearDownAll(() async {
      await storage.destroy();
      await storage.close();
      if (db == 'local-storage') {
        File('test/test-group-4').deleteSync();
      }
    });

    setUp(() async {
      await storage.truncate();

      final order1 = Order.fromJson(const {
        'orderID': 1,
        'checkoutTime': '2020-11-12 01:31:32.840',
        'discountRate': 1.0,
        'lineItems': [
          {'dishID': 0, 'dish': 'Rice Noodles', 'quantity': 2, 'price': 20000.0},
          {'dishID': 1, 'dish': 'Egg', 'quantity': 1, 'price': 5000.0},
        ],
        'isDeleted': false,
      });
      final order2 = Order.fromJson(const {
        'orderID': 2,
        'checkoutTime': '2020-11-12 02:31:32.840',
        'discountRate': 1.0,
        'lineItems': [
          {'dishID': 1, 'dish': 'Lime Juice', 'quantity': 2, 'price': 40000.0},
        ],
        'isDeleted': true,
      });
      final order3 = Order.fromJson(const {
        'orderID': 3,
        'checkoutTime': '2020-11-13 01:31:32.840',
        'discountRate': 0.1,
        'lineItems': [
          {'dishID': 0, 'dish': 'Rice Noodles', 'quantity': 5, 'price': 50000.0},
        ],
        'isDeleted': false,
      });
      final order4 = Order.fromJson(const {
        'orderID': 4,
        'checkoutTime': '2020-11-13 01:31:32.840',
        'discountRate': 0.5,
        'lineItems': [
          {'dishID': 0, 'dish': "Royce da 5'9", 'quantity': 1, 'price': 1000.0},
        ],
        'isDeleted': false,
      });

      await repo.insert(order1);
      await repo.insert(order2);
      await repo.insert(order3);
      await repo.insert(order4);
    });

    testWidgets(
      'Should have 2 lines in History page, one has strike-thru',
      (tester) async {
        await tester.pumpWidget(MaterialApp(
          builder: (_, __) => ChangeNotifierProvider(
            create: (_) {
              return HistoryOrderSupplier(
                database: repo,
                range: DateTimeRange(start: checkoutTime, end: checkoutTime), //view by same day,
              );
            },
            child: DefaultTabController(length: 2, child: HistoryScreen()),
          ),
        ));
        // see above tests for note
        await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (widget) => widget is Card,
            description: 'Line item number',
          ),
          findsNWidgets(2),
        );

        expect(
          find.byWidgetPredicate(
            (widget) => widget is Divider,
            description: 'Strike-through line across card widget',
          ),
          findsNWidgets(1),
        );
      },
    );

    testWidgets(
      'Exclude deleted item in the summary price (appbar)',
      (tester) async {
        final provider = HistoryOrderSupplier(
          database: repo,
          range: DateTimeRange(start: checkoutTime, end: checkoutTime), //view by same day,
        );

        //
        // same day
        //

        await tester.pumpWidget(MaterialApp(
          builder: (_, __) => ChangeNotifierProvider(
            create: (_) {
              return provider;
            },
            child: DefaultTabController(length: 2, child: HistoryScreen()),
          ),
        ));
        // see above tests for note
        await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(Wrap, '45,000'),
          findsOneWidget,
          reason: 'Summary price is not 45,000',
        );
        expect(
          find.text('(2020/11/12 - 2020/11/12)'),
          findsOneWidget,
          reason: 'Selected range is not 11/12',
        );

        //
        // cross day
        //
        final tomorrow = checkoutTime.add(const Duration(days: 1));
        provider.selectedRange = DateTimeRange(start: checkoutTime, end: tomorrow);
        // see above tests for note
        await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (widget) => widget is OrderCard,
          ),
          findsNWidgets(4),
          reason: 'Not finding 4 lines in view',
        );
        // (450000 * 1.0 discount)
        // + (250000 * 0.1 discount) + (1000 * 0.5 discount)
        expect(
          find.widgetWithText(Wrap, '70,500'),
          findsOneWidget,
          reason: 'Summary price is not 70,500',
        );
        expect(
          find.text('(2020/11/12 - 2020/11/13)'),
          findsOneWidget,
          reason: 'Selected range is not 11/12',
        );

        // back to one day
        provider.selectedRange = DateTimeRange(start: checkoutTime, end: checkoutTime);
        // see above tests for note
        await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        expect(
          find.widgetWithText(Wrap, '45,000'),
          findsOneWidget,
          reason: 'Summary price is not 45,000',
        );
        expect(
          find.text('(2020/11/12 - 2020/11/12)'),
          findsOneWidget,
          reason: 'Selected range is not 11/12',
        );
      },
    );
  });
}
