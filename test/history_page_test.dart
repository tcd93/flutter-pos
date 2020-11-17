import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hembo/database_factory.dart';

import 'package:hembo/models/supplier.dart';
import 'package:hembo/models/table.dart';
import 'package:hembo/screens/history.dart';
import 'package:hembo/storage_engines/connection_interface.dart';
import 'package:provider/provider.dart';

final DateTime checkoutTime = DateTime.parse('20201112 13:00:00');

void main() {
  Supplier supplier;
  TableModel checkedOutTable;
  DatabaseConnectionInterface storage;

  group('Same day report:', () {
    setUpAll(() async {
      // must set up like this to "overwrite" existing data
      // also dbName must be different in each test group
      // as we can't destroy the singleton instance...
      // (it'll use the same singleton state in every test set ups)
      storage = DatabaseFactory().create(
        'local-storage',
        'test',
        {},
        'test-group-1',
      );
      await storage.open();
    });
    tearDownAll(() {
      storage.close();
      try {
        File('test/test-group-1').deleteSync();
      } on Exception {}
      ; // delete the newly created storage file
    });
    tearDown(() async {
      try {
        await storage.destroy();
      } on Exception {}
    });

    setUp(() async {
      supplier = Supplier(
        database: storage,
        modelBuilder: (tracker) => [
          TableModel(tracker, 0)..lineItem(5).quantity = 1,
          TableModel(tracker, 1)
            ..lineItem(1).quantity = 1
            ..lineItem(2).quantity = 0
            ..lineItem(5).quantity = 1
            ..lineItem(3).quantity = 1,
        ],
      );

      // FOR SOME REASON "CHECK OUT" CAN'T BE DONE INSIDE `testWidgets`
      checkedOutTable = supplier.getTable(1);
      await checkedOutTable.checkout(checkoutTime);
    });

    testWidgets(
      'Should have 1 line in History page, price = 120,000',
      (tester) async {
        expect(checkedOutTable.totalMenuItemQuantity, 0); // confirm checked out

        await tester.pumpWidget(MaterialApp(
          builder: (_, __) => ChangeNotifierProvider(
            create: (_) => supplier,
            child: HistoryScreen(storage, checkoutTime, checkoutTime), //view by same day
          ),
        ));

        expect(
          find.byWidgetPredicate(
            (widget) => widget is Card,
            description: 'Line item number',
          ),
          findsNWidgets(1),
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
          "order_id_highkey": 2,
          "20201112": [
            {
              "orderID": 0,
              "checkoutTime": "2020-11-12 01:31:32.840",
              "totalPrice": 60000,
              "lineItems": [
                {"dishID": 0, "dishName": "Rice Noodles", "quantity": 1, "amount": 10000},
                {"dishID": 1, "dishName": "Lime Juice", "quantity": 1, "amount": 20000},
                {"dishID": 2, "dishName": "Vegan Noodle", "quantity": 1, "amount": 30000}
              ]
            },
          ],
          "20201113": [
            {
              "orderID": 1,
              "checkoutTime": "2020-11-13 01:31:47.658",
              "totalPrice": 120000,
              "lineItems": [
                {"dishID": 0, "dishName": "Rice Noodles", "quantity": 1, "amount": 10000},
                {"dishID": 4, "dishName": "Fried Chicken with Egg", "quantity": 1, "amount": 50000},
                {"dishID": 5, "dishName": "Kimchi", "quantity": 1, "amount": 60000}
              ]
            },
          ],
          "20201114": [
            {
              "orderID": 2,
              "checkoutTime": "2020-11-14 01:31:59.936",
              "totalPrice": 70000,
              "lineItems": [
                {"dishID": 6, "dishName": "Coffee", "quantity": 1, "amount": 70000}
              ]
            },
          ],
        },
        'test-group-2',
      );
      await storage.open();
    });
    tearDownAll(() {
      storage.close();
      try {
        File('test/test-group-2').deleteSync();
      } on Exception {}
      ; // delete the newly created storage file
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
          "order_id_highkey": 1,
          "20201112": [
            {
              "orderID": 0,
              "checkoutTime": "2020-11-12 01:31:32.840",
              "totalPrice": 30000,
              "lineItems": [
                {"dishID": 0, "dishName": "Rice Noodles", "quantity": 1, "amount": 10000},
                {"dishID": 1, "dishName": "Lime Juice", "quantity": 1, "amount": 20000},
              ],
              "isDeleted": false,
            },
            {
              "orderID": 1,
              "checkoutTime": "2020-11-12 02:31:32.840",
              "totalPrice": 70000,
              "lineItems": [
                {"dishID": 1, "dishName": "Lime Juice", "quantity": 2, "amount": 40000},
                {"dishID": 2, "dishName": "Vegan Noodle", "quantity": 1, "amount": 30000}
              ],
              "isDeleted": false,
            },
          ],
        },
        'test-group-3',
      );
      await storage.open();
    });
    tearDownAll(() {
      storage.close();
      try {
        File('test/test-group-3').deleteSync();
      } on Exception {}
      ; // delete the newly created storage file
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
          "order_id_highkey": 2,
          "20201112": [
            {
              "orderID": 0,
              "checkoutTime": "2020-11-12 01:31:32.840",
              "totalPrice": 25000,
              "lineItems": [
                {"dishID": 0, "dishName": "Rice Noodles", "quantity": 2, "amount": 20000},
                {"dishID": 1, "dishName": "Egg", "quantity": 1, "amount": 5000},
              ],
              "isDeleted": false,
            },
            {
              "orderID": 1,
              "checkoutTime": "2020-11-12 02:31:32.840",
              "totalPrice": 40000,
              "lineItems": [
                {"dishID": 1, "dishName": "Lime Juice", "quantity": 2, "amount": 40000},
              ],
              "isDeleted": true,
            },
          ],
          "20201113": [
            {
              "orderID": 2,
              "checkoutTime": "2020-11-13 01:31:32.840",
              "totalPrice": 50000,
              "lineItems": [
                {"dishID": 0, "dishName": "Rice Noodles", "quantity": 5, "amount": 50000},
              ],
              "isDeleted": false,
            },
          ],
        },
        'test-group-4',
      );
      await storage.open();
    });
    tearDownAll(() {
      storage.close();
      try {
        File('test/test-group-4').deleteSync();
      } on Exception {}
      ; // delete the newly created storage file
    });

    test('Confirm data access normal', () async {
      final nextInt = await storage.nextUID();
      expect(nextInt, 3);
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
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText() == '25,000 (2020/11/12 - 2020/11/12)',
          ),
          findsOneWidget,
          reason: 'Summary price is not 25,000',
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
          findsNWidgets(3),
          reason: 'Not finding 3 orders in view',
        );
        await tester.pump();

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText() == '75,000 (2020/11/12 - 2020/11/13)',
          ),
          findsOneWidget,
          reason: 'Summary price is not 75,000',
        );
      },
    );
  });
}
