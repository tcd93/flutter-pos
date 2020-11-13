import 'storage_engines/connection_interface.dart';
import 'storage_engines/local_storage.dart';

const dbName = 'hembo';

class DatabaseFactory {
  static DatabaseFactory _singleton;
  final Map<String, DatabaseConnectionInterface> _storages = {};

  DatabaseFactory._init();

  /// Returns an [DatabaseConnectionInterface] instance, currently support `local-storage`
  factory DatabaseFactory() {
    if (_singleton == null) {
      _singleton = DatabaseFactory._init();
    }

    return _singleton;
  }

  DatabaseConnectionInterface create(String name) {
    if (_storages[name] == null) {
      if (name == 'local-storage') {
        _storages[name] = LocalStorage(dbName);
      }
    }
    return _storages[name];
  }
}
