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
  static DatabaseFactory _singleton;
  static DatabaseConnectionInterface _interface;

  DatabaseFactory._init();

  /// Returns an [DatabaseConnectionInterface] instance, currently support `local-storage`
  factory DatabaseFactory(String name) {
    if (_singleton == null) {
      _singleton = DatabaseFactory._init();
    }

    if (name == 'local-storage' && _interface == null) {
      _interface = _LocalStorage(dbName);
    }

    return _singleton;
  }

  DatabaseConnectionInterface storage() => _interface;
}
