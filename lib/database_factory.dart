import 'provider/src.dart';
import 'storage_engines/connection_interface.dart';
import 'storage_engines/local_storage/local_storage.dart';
import 'storage_engines/sqlite/sqlite.dart';

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
    }
    throw UnimplementedError('$name is not implemented for database connection');
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
    if (connectionType is SQLite) {
      switch (T) {
        case Order:
          return OrderSQL(connectionType.db) as RIRepository<T>;
        case Journal:
          return JournalSQL(connectionType.db) as RIRepository<T>;
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
    if (connectionType is SQLite) {
      switch (T) {
        case Order:
          return OrderSQL(connectionType.db) as RIDRepository<T>;
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
        case Node:
          return NodeLS(connectionType.ls) as RIUDRepository<T>;
        case Config:
          return ConfigLS(connectionType.ls) as RIUDRepository<T>;
        case dynamic:
          throw 'Do not use createRIUDRepository() without specifying an object type';
        default:
          throw UnimplementedError('createRIUDRepository: unrecognized Object type');
      }
    }
    if (connectionType is SQLite) {
      switch (T) {
        case Dish:
          return MenuSQL(connectionType.db) as RIUDRepository<T>;
        case Node:
          return NodeSQL(connectionType.db) as RIUDRepository<T>;
        case dynamic:
          throw 'Do not use createRIUDRepository() without specifying an object type';
        default:
          throw UnimplementedError('createRIUDRepository: unrecognized Object type');
      }
    }
    throw UnimplementedError('createRIUDRepository: unsupported storage type');
  }
}
