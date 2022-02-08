import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/database_factory.dart';
import 'package:posapp/provider/src.dart';
import 'package:posapp/screens/edit_menu/main.dart';
import 'package:posapp/storage_engines/connection_interface.dart';
import 'package:provider/provider.dart';

void main() {
  late DatabaseConnectionInterface storage;
  const _db = String.fromEnvironment('database', defaultValue: 'sqlite');

  setUpAll(() async {
    storage = DatabaseFactory().create(_db, 'test', {}, 'menu_test');
    await storage.open();
    // supplier = MenuSupplier(database: storage, mockMenu: Menu([dish1, dish2]));
  });

  tearDownAll(() async {
    await storage.destroy();
    await storage.close();
    if (_db == 'local-storage') {
      File('test/menu_test').deleteSync();
    }
  });

  setUp(() async {
    await storage.truncate();
  });

  testWidgets('Expect default items', (tester) async {
    await tester.pumpWidget(MaterialApp(
      builder: (_, __) {
        return FutureProvider(
          create: (_) => MenuSupplier().init(),
          initialData: null,
          child: EditMenuScreen(),
        );
      },
    ));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Card,
        description: 'Menu items count',
      ),
      findsNWidgets(7),
    );
  });

  testWidgets('Expect persisting to storage', (tester) async {
    final supplier = MenuSupplier(database: storage, mockMenu: Menu());

    await tester.pumpWidget(MaterialApp(
      builder: (_, __) {
        return FutureProvider(
          create: (_) => supplier.init(),
          initialData: null,
          child: EditMenuScreen(),
        );
      },
    ));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));

    final dish = Dish(1, 'new dish', 200);
    await tester.runAsync<void>(() => supplier.addDish(dish)!);
    final menu = await tester.runAsync(() => storage.getMenu());

    expect(menu, isNotNull);
    expect(menu, isNotEmpty);
    expect(menu!.length, 1);
    expect(menu.elementAt(0), dish);
  });
}
