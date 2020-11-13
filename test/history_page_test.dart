import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hembo/database_factory.dart';

import 'package:hembo/models/supplier.dart';
import 'package:hembo/models/table.dart';
import 'package:hembo/screens/history.dart';
import 'package:provider/provider.dart';

final DateTime checkoutTime = DateTime.parse('20201112 13:00:00');

void main() {
  Supplier supplier;
  TableModel checkedOutTable;
  Widget skeletonWidget;

  setUp(() async {
    supplier = Supplier(
      database: DatabaseFactory().create('local-storage'),
      modelBuilder: (tracker) => [
        TableModel(tracker, 1)..lineItem(5).quantity = 1,
        TableModel(tracker, 1)
          ..lineItem(1).quantity = 1
          ..lineItem(2).quantity = 0
          ..lineItem(5).quantity = 1
          ..lineItem(3).quantity = 1,
      ],
    );

    checkedOutTable = supplier.getTable(1);
    await checkedOutTable.checkout(checkoutTime); // table with 4 line items

    skeletonWidget = MaterialApp(
      builder: (_, __) => ChangeNotifierProvider(
        create: (_) => supplier,
        child: HistoryScreen(checkoutTime, checkoutTime), //view by today
      ),
    );
  });

  tearDown(() async {
    await DatabaseFactory().create('local-storage').destroy();
  });

  testWidgets(
    'Should have 1 line in History page, price = 120,000',
    (tester) async {
      await tester.pumpWidget(skeletonWidget);

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
}
