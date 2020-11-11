import 'storage_engines/connection_interface.dart';
import 'storage_engines/local_storage.dart';

const dbName = 'hembo';

class DatabaseFactory {
  static DatabaseFactory _singleton;
  static DatabaseConnectionInterface _storage;

  DatabaseConnectionInterface get storage => _storage;

  DatabaseFactory._init();

  /// Returns an [DatabaseConnectionInterface] instance, currently support `local-storage`
  factory DatabaseFactory(String name) {
    if (_singleton == null) {
      _singleton = DatabaseFactory._init();
    }

    if (name == 'local-storage' && _storage == null) {
      _storage = LocalStorage(dbName);
    }

    if (_storage == null) {
      throw Exception('Must define a storage type name');
    }

    return _singleton;
  }
}
