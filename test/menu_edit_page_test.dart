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
  late RIUDRepository<Dish> repo;
  const db = String.fromEnvironment('database', defaultValue: 'local-storage');

  setUpAll(() async {
    storage = DatabaseFactory().create(db, 'test', {}, 'menu_test');
    await storage.open();
    repo = DatabaseFactory().createRIUDRepository(storage);
    // supplier = MenuSupplier(database: storage, mockMenu: Menu([dish1, dish2]));
  });

  tearDownAll(() async {
    await storage.destroy();
    await storage.close();
    if (db == 'local-storage') {
      File('test/menu_test').deleteSync();
    }
  });

  setUp(() async {
    await storage.truncate();
  });

  testWidgets('Expect default items', (tester) async {
    await tester.pumpWidget(MaterialApp(
      builder: (_, __) {
        return ChangeNotifierProvider(
          create: (_) => MenuSupplier(),
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
    final supplier = MenuSupplier(database: repo, mockMenu: []);

    await tester.pumpWidget(MaterialApp(
      builder: (_, __) {
        return ChangeNotifierProvider(
          create: (_) => supplier,
          child: EditMenuScreen(),
        );
      },
    ));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));

    var dish = await tester.runAsync<Dish>(() => supplier.addDish('new dish', 200));
    var menu = await tester.runAsync(() => repo.get());

    expect(menu, isNotNull);
    expect(menu, isNotEmpty);
    expect(menu!.length, 1);
    expect(menu.elementAt(0).toJson(), dish!.toJson());

    var dish2 = await tester.runAsync<Dish>(() => supplier.addDish('new dish 2', 300));
    menu = await tester.runAsync(() => repo.get());
    expect(menu!.length, 2);
    expect(menu.elementAt(1).toJson(), dish2!.toJson());

    await tester.runAsync<void>(() => supplier.updateDish(dish, 'XXX', 100));
    menu = await tester.runAsync(() => repo.get());
    expect(menu!.elementAt(0).id, 1);
    expect(menu.elementAt(0).dish, 'XXX');
    expect(menu.elementAt(0).price, 100);

    await tester.runAsync<void>(() => supplier.removeDish(dish2));
    menu = await tester.runAsync(() => repo.get());
    expect(menu!.length, 1);
    expect(menu.elementAt(0).dish, 'XXX');
    expect(menu.elementAt(0).price, 100);
  });
}
