import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/database_factory.dart';
import 'package:posapp/provider/src.dart';
import 'package:posapp/screens/history/main.dart';

final DateTime checkoutTime = DateTime.parse('20201112 13:00:00');

void main() {
  Supplier supplier;
  var checkedOutTable = TableModel(-1);
  var storage = DatabaseFactory().create('local-storage');

  group('Same day report:', () {
    setUpAll(() async {
      storage = DatabaseFactory().create('local-storage', 'test', {}, 'test-group-1');
      await storage.open();
    });
    tearDownAll(() async {
      await storage.destroy();
      storage.close();
      // .close() is async, but lib does not await...
      await Future.delayed(Duration(milliseconds: 500));
      try {
        File('test/test-group-1').deleteSync();
      } on Exception catch (e) {
        print('\x1B[94mtearDownAll (test/test-group-1): $e\x1B[0m');
      }
      // delete the newly created storage file
    });

    setUp(() async {
      final testTableID = 1;
      supplier = Supplier(
        database: storage,
        mockModels: [
          TableModel(0),
          TableModel(
            1,
            TableState.mock(
              1,
              List.generate(
                1,
                (index) => LineItem(
                  associatedDish: Dish(index, 'Test Dish $index', 120000),
                  quantity: 1,
                ),
              ),
            ),
          ),
        ],
      );
      checkedOutTable = supplier.getTable(testTableID);

      // FOR SOME REASON "CHECK OUT" CAN'T BE DONE INSIDE `testWidgets`
      await checkedOutTable.checkout(supplier: supplier, atTime: checkoutTime);
    });

    testWidgets(
      'Should have 1 line in History page, price = 120,000',
      (tester) async {
        expect(checkedOutTable.totalMenuItemQuantity, 0); // confirm checked out

        await tester.pumpWidget(MaterialApp(
          builder: (_, __) => HistoryScreen(storage, checkoutTime, checkoutTime),
        ));

        expect(
          find.byWidgetPredicate(
            (widget) => widget is Card,
            description: 'Line item number',
          ),
          findsOneWidget,
        );

        expect(
          find.text('120,000'),
          findsOneWidget,
          reason: 'Total price should be 120,000',
        );
      },
    );
  });

  group('Cross day report:', () {
    setUpAll(() async {
      // create existing checked out data
      storage = DatabaseFactory().create(
        'local-storage',
        'test',
        {
          'order_id_highkey': 2,
          '20201112': [
            {
              'orderID': 0,
              'checkoutTime': '2020-11-12 01:31:32.840',
              'discountRate': 1.0,
              'lineItems': [
                {'dishID': 0, 'dishName': 'Rice Noodles', 'quantity': 1, 'price': 10000.0},
                {'dishID': 1, 'dishName': 'Lime Juice', 'quantity': 1, 'price': 20000.0},
                {'dishID': 2, 'dishName': 'Vegan Noodle', 'quantity': 1, 'price': 30000.0}
              ]
            },
          ],
          '20201113': [
            {
              'orderID': 1,
              'checkoutTime': '2020-11-13 01:31:47.658',
              'discountRate': 1.0,
              'lineItems': [
                {'dishID': 0, 'dishName': 'Rice Noodles', 'quantity': 1, 'price': 10000.0},
                {
                  'dishID': 4,
                  'dishName': 'Fried Chicken with Egg',
                  'quantity': 1,
                  'price': 50000.0
                },
                {'dishID': 5, 'dishName': 'Kimchi', 'quantity': 1, 'price': 60000.0}
              ]
            },
          ],
          '20201114': [
            {
              'orderID': 2,
              'checkoutTime': '2020-11-14 01:31:59.936',
              'discountRate': 1.0,
              'lineItems': [
                {'dishID': 6, 'dishName': 'Coffee', 'quantity': 1, 'price': 70000.0}
              ]
            },
          ],
        },
        'test-group-2',
      );
      await storage.open();
    });
    tearDownAll(() async {
      await storage.destroy();
      storage.close();
      // .close() is async, but lib does not await...
      await Future.delayed(Duration(milliseconds: 500));
      try {
        File('test/test-group-2').deleteSync();
      } on Exception catch (e) {
        print('\x1B[94mtearDownAll (test/test-group-2): $e\x1B[0m');
      }
      // delete the newly created storage file
    });

    test('Confirm data access normal', () async {
      final nextInt = await storage.nextUID();
      expect(nextInt, 3);
    });

    testWidgets(
      'Should have 2 line in History page, price = 180,000',
      (tester) async {
        // but only view by 2 days
        await tester.pumpWidget(MaterialApp(
          builder: (_, __) => HistoryScreen(
            storage,
            checkoutTime,
            checkoutTime.add(const Duration(days: 1)),
          ),
        ));

        expect(
          find.byWidgetPredicate(
            (widget) => widget is Card,
            description: 'Line item number',
          ),
          findsNWidgets(2),
        );

        expect(
          find.text('120,000'),
          findsOneWidget,
          reason: 'Price of first line item',
        );

        expect(
          find.text('60,000'),
          findsOneWidget,
          reason: 'Price of second line item',
        );
      },
    );
  });

  group('Soft delete order test:', () {
    setUpAll(() async {
      // create existing checked out data
      storage = DatabaseFactory().create(
        'local-storage',
        'test',
        {
          'order_id_highkey': 1,
          '20201112': [
            {
              'orderID': 0,
              'checkoutTime': '2020-11-12 01:31:32.840',
              'discountRate': 1.0,
              'lineItems': [
                {'dishID': 0, 'dishName': 'Rice Noodles', 'quantity': 1, 'price': 10000.0},
                {'dishID': 1, 'dishName': 'Lime Juice', 'quantity': 1, 'price': 20000.0},
              ],
              'isDeleted': false,
            },
            {
              'orderID': 1,
              'checkoutTime': '2020-11-12 02:31:32.840',
              'discountRate': 1.0,
              'lineItems': [
                {'dishID': 1, 'dishName': 'Lime Juice', 'quantity': 2, 'price': 40000.0},
                {'dishID': 2, 'dishName': 'Vegan Noodle', 'quantity': 1, 'price': 30000.0}
              ],
              'isDeleted': false,
            },
          ],
        },
        'test-group-3',
      );
      await storage.open();
    });
    tearDownAll(() async {
      await storage.destroy();
      storage.close();
      // .close() is async, but lib does not await...
      await Future.delayed(Duration(milliseconds: 500));
      try {
        File('test/test-group-3').deleteSync();
      } on Exception catch (e) {
        print('\x1B[94mteardownAll (test/test-group-3): $e\x1B[0m');
      }
      // delete the newly created storage file
    });

    test('Confirm data access normal', () async {
      final nextInt = await storage.nextUID();
      expect(nextInt, 2);
    });

    test('Should be able to set isDeleted to true', () async {
      await storage.delete(DateTime.parse('2020-11-12'), 1);

      var order = storage.get(DateTime.parse('2020-11-12'));

      expect(order[0].isDeleted, false);
      expect(order[1].isDeleted, true);
    });
  });

  group('Soft delete order widget test:', () {
    setUpAll(() async {
      // create existing checked out data
      storage = DatabaseFactory().create(
        'local-storage',
        'test',
        {
          'order_id_highkey': 3,
          '20201112': [
            {
              'orderID': 0,
              'checkoutTime': '2020-11-12 01:31:32.840',
              'discountRate': 1.0,
              'lineItems': [
                {'dishID': 0, 'dishName': 'Rice Noodles', 'quantity': 2, 'price': 20000.0},
                {'dishID': 1, 'dishName': 'Egg', 'quantity': 1, 'price': 5000.0},
              ],
              'isDeleted': false,
            },
            {
              'orderID': 1,
              'checkoutTime': '2020-11-12 02:31:32.840',
              'discountRate': 1.0,
              'lineItems': [
                {'dishID': 1, 'dishName': 'Lime Juice', 'quantity': 2, 'price': 40000.0},
              ],
              'isDeleted': true,
            },
          ],
          '20201113': [
            {
              'orderID': 2,
              'checkoutTime': '2020-11-13 01:31:32.840',
              'discountRate': 0.1,
              'lineItems': [
                {'dishID': 0, 'dishName': 'Rice Noodles', 'quantity': 5, 'price': 50000.0},
              ],
              'isDeleted': false,
            },
            {
              'orderID': 3,
              'checkoutTime': '2020-11-13 01:31:32.840',
              'discountRate': 0.5,
              'lineItems': [
                {'dishID': 0, 'dishName': "Royce da 5'9", 'quantity': 1, 'price': 1000.0},
              ],
              'isDeleted': false,
            },
          ],
        },
        'test-group-4',
      );
      await storage.open();
    });
    tearDownAll(() async {
      await storage.destroy();
      storage.close();
      // .close() is async, but lib does not await...
      await Future.delayed(Duration(milliseconds: 500));
      try {
        File('test/test-group-4').deleteSync();
      } on Exception catch (e) {
        print('\x1B[94mtearDownAll: (test/test-group-4)$e\x1B[0m');
      }
      // delete the newly created storage file
    });

    test('Confirm data access normal', () async {
      final nextInt = await storage.nextUID();
      expect(nextInt, 4);
    });

    testWidgets(
      'Should have 2 lines in History page, one has strike-thru',
      (tester) async {
        await tester.pumpWidget(MaterialApp(
          builder: (_, __) =>
              HistoryScreen(storage, checkoutTime, checkoutTime), //view by same day,
        ));

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
        final tomorrow = checkoutTime.add(const Duration(days: 1));

        //
        // same day
        //

        await tester.pumpWidget(MaterialApp(
          builder: (_, __) => HistoryScreen(storage, checkoutTime, checkoutTime),
        ));

        expect(
          find.text('45,000'),
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
        await tester.pumpWidget(MaterialApp(
          builder: (_, __) => HistoryScreen(storage, checkoutTime, tomorrow),
        ));

        expect(
          find.byWidgetPredicate(
            (widget) => widget is Card,
          ),
          findsNWidgets(4),
          reason: 'Not finding 3 orders in view',
        );
        await tester.pump();

        // (450000 * 1.0 discount)
        // + (250000 * 0.1 discount) + (1000 * 0.5 discount)
        expect(
          find.text('70,500'),
          findsOneWidget,
          reason: 'Summary price is not 70,500',
        );
        expect(
          find.text('(2020/11/12 - 2020/11/13)'),
          findsOneWidget,
          reason: 'Selected range is not 11/12',
        );
      },
    );
  });
}
