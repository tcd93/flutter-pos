// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hembo/models/supplier.dart';
import 'package:hembo/models/table.dart';
import 'package:hembo/screens/details.dart';
import 'package:provider/provider.dart';

Widget skeletonWidget() => MaterialApp(
      builder: (_, __) => ChangeNotifierProvider(
        create: (_) => Supplier(
          modelBuilder: (tracker) => [
            TableModel(tracker, 1)..lineItem(5).quantity = 1,
            TableModel(tracker, 1)
              ..lineItem(1).quantity = 5
              ..lineItem(2).quantity = 0
              ..lineItem(5).quantity = 55
              ..lineItem(3).quantity = 10,
          ],
        ),
        child: DetailsScreen(1),
      ),
    );

void main() {
  testWidgets(
    'Should have 3 line in details page for order that have 3 line items',
    (tester) async {
      await tester.pumpWidget(skeletonWidget());

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Card,
          description: 'Line item in details page',
        ),
        findsNWidgets(3), // 3 distinct widgets in table1's order
      );
    },
  );
}
