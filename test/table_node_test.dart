import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/database_factory.dart';
import 'package:posapp/provider/src.dart';
import 'package:posapp/storage_engines/connection_interface.dart';

void main() {
  late DatabaseConnectionInterface storage;
  late RIUDRepository<Node> repo;
  const db = String.fromEnvironment('database', defaultValue: 'local-storage');

  setUpAll(() async {
    storage = DatabaseFactory().create(db, 'test', {}, 'node_test');
    await storage.open();
    repo = DatabaseFactory().createRIUDRepository(storage);
  });

  tearDownAll(() async {
    await storage.destroy();
    await storage.close();
    if (db == 'local-storage') {
      File('test/node_test').deleteSync();
    }
  });

  setUp(() async {
    await storage.truncate();
  });

  testWidgets('Create/edit a table node', (tester) async {
    final supplier = NodeSupplier(database: repo);
    await tester.pumpAndSettle();

    var newID = await tester.runAsync<int?>(() => supplier.addNode(0));
    expect(newID, 1);

    var ids = await tester.runAsync(() => repo.get());
    expect(ids!.length, 1);
    expect(ids[0].id, 1);

    // add second node
    newID = await tester.runAsync<int?>(() => supplier.addNode(0));
    expect(newID, 2);

    ids = await tester.runAsync(() => repo.get());
    expect(ids!.length, 2);
    expect(ids[1].id, 2);

    // remove first node
    await tester.runAsync(() => supplier.removeNode(supplier.nodes(0).first));
    expect(() => supplier.nodes(0).firstWhere((t) => t.id == 1), throwsStateError);

    ids = await tester.runAsync(() => repo.get());
    expect(ids!.length, 1);
  });
}
