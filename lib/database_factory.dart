import 'package:localstorage/localstorage.dart';

const dbName = 'hembo';

class DatabaseConnectionInterface {
  /// Used in [FutureBuilder]
  Future<dynamic> open() {
    return Future.value(null);
  }
}

class _LocalStorage implements DatabaseConnectionInterface {
  final LocalStorage ls;

  _LocalStorage(String name, [String path, Map<String, dynamic> initialData])
      : ls = LocalStorage(name, path, initialData);

  @override
  Future<bool> open() async {
    return ls.ready;
  }
}

class DatabaseFactory {
  /// Returns an [DatabaseConnectionInterface] instance, currently support `local-storage`
  static DatabaseConnectionInterface pickConnection(String name) {
    if (name == 'local-storage') {
      return _LocalStorage(dbName);
    }
    return null;
  }
}
