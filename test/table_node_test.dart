import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/database_factory.dart';
import 'package:posapp/provider/src.dart';
import 'package:posapp/screens/lobby/main.dart';
import 'package:posapp/storage_engines/connection_interface.dart';
import 'package:provider/provider.dart';

void main() {
  late DatabaseConnectionInterface storage;
  const _db = String.fromEnvironment('database', defaultValue: 'sqlite');

  setUpAll(() async {
    storage = DatabaseFactory().create(_db, 'test', {}, 'node_test');
    await storage.open();
  });

  tearDownAll(() async {
    await storage.destroy();
    storage.close();
    // .close() is async, but lib does not await...
    await Future.delayed(const Duration(milliseconds: 300));
    if (_db == 'local-storage') {
      File('test/node_test').deleteSync();
    }
  });

  setUp(() async {
    await storage.truncate();
  });

  testWidgets('Create/edit a table node', (tester) async {
    final supplier = Supplier(database: storage);

    await tester.pumpWidget(MaterialApp(
      builder: (_, child) {
        return ChangeNotifierProvider(
          create: (_) => Supplier(database: storage),
          child: child,
        );
      },
      home: LobbyScreen(),
    ));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    var newID = await tester.runAsync<int?>(() => supplier.addTable());
    expect(newID, 1);
    var table = supplier.getTable(1);
    expect(table.id, 1);

    var ids = await tester.runAsync(() => storage.tableIDs());
    expect(ids!.length, 1);
    expect(ids[0], 1);

    // add second node
    newID = await tester.runAsync<int?>(() => supplier.addTable());
    expect(newID, 2);
    table = supplier.getTable(2);
    expect(table.id, 2);

    ids = await tester.runAsync(() => storage.tableIDs());
    expect(ids!.length, 2);
    expect(ids[1], 2);

    // remove first node
    await tester.runAsync(() => supplier.removeTable(1));
    expect(() => supplier.getTable(1), throwsStateError);

    ids = await tester.runAsync(() => storage.tableIDs());
    expect(ids!.length, 1);
  });
}
