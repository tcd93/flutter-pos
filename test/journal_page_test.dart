import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/database_factory.dart';
import 'package:posapp/provider/src.dart';
import 'package:posapp/screens/expense_journal/journal_card.dart';
import 'package:posapp/screens/expense_journal/main.dart';
import 'package:posapp/storage_engines/connection_interface.dart';
import 'package:provider/provider.dart';

final DateTime time = DateTime.parse('20201112 13:00:00');

void main() {
  late DatabaseConnectionInterface storage;
  late RIRepository<Journal> repo;
  const db = String.fromEnvironment('database', defaultValue: 'local-storage');

  setUpAll(() async {
    storage = DatabaseFactory().create(db, 'test', {}, 'journal-test-1');
    await storage.open();
    repo = DatabaseFactory().createRIRepository(storage);
  });
  tearDownAll(() async {
    await storage.destroy();
    await storage.close();
    if (db == 'local-storage') {
      File('test/journal-test-1').deleteSync();
    }
  });

  setUp(() async {
    await storage.truncate();
  });

  testWidgets(
    'Should have 1 line in Expense page',
    (tester) async {
      await tester.runAsync(
        () => repo.insert(Journal(
          entry: 'test entry',
          entryTime: time,
          amount: 1000,
        )),
      );

      await tester.pumpWidget(MaterialApp(
        builder: (_, __) => ChangeNotifierProvider(
          create: (_) {
            return ExpenseSupplier(
              database: repo,
              range: DateTimeRange(start: time, end: time),
            );
          },
          child: ExpenseJournalScreen(),
        ),
      ));

      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((widget) => widget is JournalCard),
        findsOneWidget,
      );

      expect(
        find.widgetWithText(JournalCard, 'test entry'),
        findsOneWidget,
      );
    },
  );
}
