import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/provider/src.dart';
import 'package:posapp/screens/order_details/main.dart';
import 'package:provider/provider.dart';

void main() {
  final table = TableModel(
    1,
    TableState.mock(
      1,
      List.generate(
        3,
        (index) => LineItem(
          associatedDish: Dish(index + 1, 'Test Dish $index', 3333),
          quantity: (index + 1) * 2,
        ),
      ),
    ),
  );

  setUpAll(() async {
    await Menu().load();
  });

  testWidgets(
    'Should have 3 line in details page for order that have 3 line items',
    (tester) async {
      await tester.pumpWidget(MaterialApp(
        builder: (_, __) {
          return ChangeNotifierProvider(
            create: (_) => Supplier(),
            child: DetailsScreen(table, fromScreen: ''),
          );
        },
      ));
      // fix some timer test bug
      await tester.pumpAndSettle(const Duration(seconds: 1));
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
