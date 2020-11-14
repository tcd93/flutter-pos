import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hembo/database_factory.dart';
import 'package:hembo/storage_engines/connection_interface.dart';

void main() {
  DatabaseConnectionInterface storage;

  setUpAll(() async {
    // must set up like this to "overwrite" existing data
    storage = DatabaseFactory().create('local-storage', 'test', {});
    await storage.open();
  });
  tearDownAll(() {
    storage.close();
    File('test/hembo').deleteSync(); // delete the newly created storage file
  });
  tearDown(() async {
    try {
      await storage.destroy();
    } on Exception {}
  });

  test('Test UID consistently increasing to 1', () async {
    final uid = await storage.nextUID();
    expect(uid, 0);

    final uid1 = await storage.nextUID();
    expect(uid1, 1);
  });

  test('Test UID reset (tearDown func should work)', () async {
    final uid = await storage.nextUID();
    expect(uid, 0);
  });
}
