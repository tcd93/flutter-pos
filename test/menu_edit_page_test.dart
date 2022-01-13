import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/database_factory.dart';
import 'package:posapp/provider/src.dart';
import 'package:posapp/screens/edit_menu/main.dart';
import 'package:posapp/storage_engines/connection_interface.dart';
import 'package:provider/provider.dart';

void main() {
  late DatabaseConnectionInterface storage;
  // late MenuSupplier supplier;
  // final dish1 = Dish(1, 'dish 1', 1000);
  // final dish2 = Dish(2, 'dish 2', 2000);

  setUpAll(() async {
    storage = DatabaseFactory().create('local-storage', 'test', {'test': 1}, 'menu_test');
    await storage.open();
    // supplier = MenuSupplier(database: storage, mockMenu: Menu([dish1, dish2]));
  });

  tearDown(() async {
    try {
      await storage.destroy();
    } on Exception catch (e) {
      if (kDebugMode) {
        print('\x1B[94m $e\x1B[0m');
      }
    }
  });

  tearDownAll(() async {
    storage.close();
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      File('test/menu_test').deleteSync();
    } on Exception catch (e) {
      if (kDebugMode) {
        print('\x1B[94mtearDownAll (test/menu-test): $e\x1B[0m');
      }
    }
  });

  testWidgets('Expect default items', (tester) async {
    await tester.pumpWidget(MaterialApp(
      builder: (_, __) {
        return Provider(
          create: (_) => MenuSupplier(),
          child: EditMenuScreen(),
        );
      },
    ));

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Card,
        description: 'Menu items count',
      ),
      findsNWidgets(7),
    );
  });

  // this test is not working on Windows machine?
  //
  // testWidgets('Expect persisting to storage', (tester) async {
  //   await tester.pumpWidget(MaterialApp(
  //     builder: (_, __) {
  //       return Provider(
  //         create: (_) => supplier,
  //         child: EditMenuScreen(),
  //       );
  //     },
  //   ));

  //   final newDish = Dish(3, 'new name', 200);
  //   await supplier.addDish(newDish);
  //   final menu = storage.getMenu()!;

  //   expect(menu, isNotEmpty);
  //   expect(menu.list[2].dish, 'new name');
  //   expect(menu.list[2].price, 200);
  // });
}
