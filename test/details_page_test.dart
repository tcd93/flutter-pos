import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hembo/models/immutable/order.dart';

import 'package:hembo/screens/details.dart';

void main() {
  Widget skeletonWidget() => MaterialApp(
        builder: (_, __) {
          return DetailsScreen(
            Order(
              1,
              null,
              null,
              10000,
              List.generate(3, (index) => OrderItem(index, 'Test Dish $index', index * 2, 3333)),
            ),
          );
        },
      );
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
