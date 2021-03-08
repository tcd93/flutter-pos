import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/database_factory.dart';

void main() {
  var storage = DatabaseFactory().create('local-storage', 'test', {}, 'storage_engine_test');

  setUpAll(() async {
    await storage.open();
  });
  tearDownAll(() async {
    storage.close();
    await Future.delayed(Duration(milliseconds: 500));
    File('test/storage_engine_test').deleteSync(); // delete the newly created storage file
  });
  tearDown(() async {
    try {
      await storage.destroy();
    } on Exception catch (e) {
      print('\x1B[94m $e\x1B[0m');
    }
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
