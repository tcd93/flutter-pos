import 'package:posapp/storage_engines/sqlite.dart';

import 'provider/src.dart';
import 'storage_engines/connection_interface.dart';
import 'storage_engines/local_storage/local_storage.dart';

const appName = 'posapp';

class DatabaseFactory {
  static final DatabaseFactory _singleton = DatabaseFactory._init();

  DatabaseFactory._init();

  /// Returns an [DatabaseConnectionInterface] instance, currently support `local-storage`, 'sqlite'
  factory DatabaseFactory() {
    return _singleton;
  }

  DatabaseConnectionInterface create(
    String name, [
    String? path,
    Map<String, dynamic>? initialData,
    String? dbName,
  ]) {
    if (name == 'local-storage') {
      return LocalStorage(dbName ?? appName, path, initialData);
    }
    if (name == 'sqlite') {
      return SQLite(dbName ?? appName, path);
    } else {
      throw UnimplementedError('$name is not implemented for database connection');
    }
  }

  RIRepository<T> createRIRepository<T>(DatabaseConnectionInterface connectionType) {
    if (connectionType is LocalStorage) {
      switch (T) {
        case Order:
          return OrderLS(connectionType.ls) as RIRepository<T>;
        case Journal:
          return JournalLS(connectionType.ls) as RIRepository<T>;
        case dynamic:
          throw 'Do not use createRIRepository() without specifying an object type';
        default:
          throw UnimplementedError('createRIRepository: unrecognized Object type');
      }
    }
    throw UnimplementedError('createRIRepository: unsupported storage type');
  }

  RIDRepository<T> createRIDRepository<T>(DatabaseConnectionInterface connectionType) {
    if (connectionType is LocalStorage) {
      switch (T) {
        case Order:
          return OrderLS(connectionType.ls) as RIDRepository<T>;
        case dynamic:
          throw 'Do not use createRIDRepository() without specifying an object type';
        default:
          throw UnimplementedError('createRIDRepository: unrecognized Object type');
      }
    }
    throw UnimplementedError('createRIDRepository: unsupported storage type');
  }

  RIUDRepository<T> createRIUDRepository<T>(DatabaseConnectionInterface connectionType) {
    if (connectionType is LocalStorage) {
      switch (T) {
        case Dish:
          return MenuLS(connectionType.ls) as RIUDRepository<T>;
        case dynamic:
          throw 'Do not use createRIUDRepository() without specifying an object type';
        default:
          throw UnimplementedError('createRIDRepository: unrecognized Object type');
      }
    }
    throw UnimplementedError('createRIUDRepository: unsupported storage type');
  }
}
