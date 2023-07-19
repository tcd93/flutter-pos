import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../common/common.dart';
import '../../provider/src.dart';
import '../connection_interface.dart';

const String nodeTable = 'nodes';
const String orderTable = 'orders';
const String lineItemTable = 'lineItems';
const String dishTable = 'dish';
const String journalTable = 'journal';

/// merge multi-line results of sqlite rawQuery into list of [Order] objects
@visibleForTesting
List<Map<String, Object?>> mergeRaws(List<Map<String, Object?>> rawResults) {
  return rawResults.fold<List<Map<String, Object?>>>([], (list, element) {
    // new order
    if (list.isEmpty || list.last['ID'] != element['ID']) {
      return [
        ...list,
        {
          'ID': element['ID'],
          'checkoutTime':
              '${element['date']! as String} ${element['time']! as String}',
          'tableID': element['tableID'],
          'status': element['status'],
          'discountRate': element['discountRate'],
          'isDeleted': element['isDeleted'] == 1,
          'lineItems': [
            {
              'orderID': element['orderID'],
              'dishID': element['dishID'],
              'dish': element['dish'],
              'price': element['price'],
              'quantity': element['quantity'],
            },
          ],
        }
      ];
    } else {
      // append new lineItem to last order
      final lastOrder = list.last;
      (lastOrder['lineItems'] as List).add({
        'orderID': element['orderID'],
        'dishID': element['dishID'],
        'dish': element['dish'],
        'price': element['price'],
        'quantity': element['quantity'],
      });
      return list;
    }
  });
}

class SQLite implements DatabaseConnectionInterface {
  final String name;

  /// Should be initialized if you do a [open] check beforehand
  late Database db;
  String? path;
  Map<String, dynamic>? initialData;

  final Completer<bool> _completer = Completer();

  SQLite(this.name, [this.path]) {
    if (name == '') return;
    // use ffi for windows and linux as base sqflite package only work on mobile platform
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    Future(() async {
      final dtb = await openDatabase(
        join(path ?? await getDatabasesPath(), '$name.db'),
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $nodeTable(
              ID           INTEGER PRIMARY KEY AUTOINCREMENT, 
              x            REAL DEFAULT 0,
              y            REAL DEFAULT 0,
              name         TEXT,
              page         INT
            )
          ''');
          await db.execute('''
            CREATE TABLE $orderTable(
              ID           INTEGER PRIMARY KEY AUTOINCREMENT, 
              date         TEXT, -- YYYYMMDD
              time         TEXT, -- HH24:MM:SS
              tableID      INTEGER, 
              status       TINYINT,
              discountRate REAL,
              isDeleted    BOOLEAN
            )
            ''');
          await db.execute(
              'CREATE INDEX ${orderTable}Idx ON $orderTable (date, ID)');
          await db.execute('''
            CREATE TABLE $dishTable(
              ID             INTEGER PRIMARY KEY AUTOINCREMENT, 
              price          REAL,
              dish           TEXT,
              imageBytes     BLOB,
              asset          TEXT
            )
            ''');
          await db.execute('''
            CREATE TABLE $lineItemTable(
              orderID        INTEGER,
              dishID         INT,
              dish           TEXT,
              price          REAL,
              quantity       INT,
              FOREIGN KEY(orderID) REFERENCES $orderTable(ID),
              FOREIGN KEY(dishID) REFERENCES $dishTable(ID)
            )
            ''');
          await db.execute(
              'CREATE INDEX ${lineItemTable}Idx ON $lineItemTable (orderID)');
          await db.execute('''
            CREATE TABLE $journalTable(
              ID           INTEGER PRIMARY KEY AUTOINCREMENT, 
              date         TEXT, -- YYYYMMDD
              time         TEXT, -- HH24:MM:SS
              entry        TEXT, 
              amount       REAL
            )
            ''');
          await db.execute(
              'CREATE INDEX ${journalTable}Idx ON $journalTable (date, ID)');
          if (kDebugMode) {
            print('Table Creation complete');
          }
        },
        version: 1,
      );
      if (kDebugMode) {
        print(
            'Initiating sqlite database at path: ${await getDatabasesPath()}');
      }
      db = dtb;
      _completer.complete(dtb.isOpen);
    });
  }

  @override
  Future<void> truncate() {
    if (db.isOpen) {
      return db.execute('''
        DELETE FROM $orderTable;
        DELETE FROM $lineItemTable;
        DELETE FROM $dishTable;
        DELETE FROM $nodeTable;
        DELETE FROM $journalTable;
        DELETE FROM sqlite_sequence WHERE name='$orderTable';
        DELETE FROM sqlite_sequence WHERE name='$lineItemTable';
        DELETE FROM sqlite_sequence WHERE name='$dishTable';
        DELETE FROM sqlite_sequence WHERE name='$nodeTable';
        DELETE FROM sqlite_sequence WHERE name='$journalTable';
      ''');
    }
    throw 'Database is not opened';
  }

  @override
  Future<bool> open() => _completer.future;

  @override
  Future<void> close() => db.close();

  @override
  Future<void> destroy() => deleteDatabase(db.path);
}

class OrderSQL extends RIDRepository<Order>
    implements Readable<Order>, Insertable<Order>, Deletable<Order> {
  final Database db;
  OrderSQL(this.db);

  @override
  Future<List<Order>> get([QueryKey? from, QueryKey? to]) async {
    assert(from is DateTime);
    assert(() {
      if (to != null) return to is DateTime;
      return true;
    }());

    final rawResults = await db.rawQuery('''
      SELECT *
        FROM $orderTable o
        JOIN $lineItemTable l
          ON o.ID = l.orderID
       WHERE o.date BETWEEN ? AND ?
       ORDER BY o.ID
    ''', [
      Common.extractYYYYMMDD(from as DateTime),
      Common.extractYYYYMMDD((to ?? from) as DateTime)
    ]);

    if (rawResults.isEmpty) {
      return [];
    }
    return mergeRaws(rawResults).map((i) => Order.fromJson(i)).toList();
  }

  @override
  Future<Order> insert(Order value) {
    return db.transaction((txn) async {
      final orderID = await txn.insert(
        orderTable,
        {
          'date': Common.extractYYYYMMDD(value.checkoutTime),
          'time': Common.extractTime(value.checkoutTime),
          'tableID': value.tableID,
          'status': value.status.index,
          'discountRate': value.discountRate,
          'isDeleted': value.isDeleted ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );

      if (orderID == 0) {
        throw 'No rows were inserted';
      }

      final batch = txn.batch();
      for (final li in value.lineItems) {
        batch.insert(
          lineItemTable,
          {
            'orderID': orderID,
            'dishID': li.dishID,
            'dish': li.dishName,
            'price': li.price,
            'quantity': li.quantity,
          },
          conflictAlgorithm: ConflictAlgorithm.fail,
        );
      }
      await batch.commit(noResult: true);
      return Order.fromJson({
        ...value.toJson(),
        ...{'ID': orderID}
      });
    });
  }

  /// soft-delete by marking [Order.isDeleted] = true
  @override
  Future<void> delete(Order value) async {
    final r = await db.update(
      orderTable,
      {
        'isDeleted': 1,
      },
      where: 'date = ? AND ID = ?',
      whereArgs: [Common.extractYYYYMMDD(value.checkoutTime), value.id],
    );
    if (r <= 0) {
      throw 'Can not update a non-existing order with ID = ${value.id}';
    }
  }
}

class JournalSQL extends RIRepository<Journal>
    with Readable<Journal>, Insertable<Journal> {
  final Database db;
  JournalSQL(this.db);

  @override
  Future<List<Journal>> get([QueryKey? from, QueryKey? to]) async {
    assert(from is DateTime);
    assert(to is DateTime);

    final rawResults = await db.query(
      journalTable,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        Common.extractYYYYMMDD(from as DateTime),
        Common.extractYYYYMMDD(to as DateTime)
      ],
    );

    if (rawResults.isEmpty) {
      return [];
    }
    return rawResults.map((j) {
      final json = {
        'ID': j['ID'],
        'dateTime': '${j['date']! as String} ${j['time']! as String}',
        'entry': j['entry'],
        'amount': j['amount'],
      };
      return Journal.fromJson(json);
    }).toList();
  }

  @override
  Future<Journal> insert(Journal value) async {
    final id = await db.insert(
      journalTable,
      {
        'date': Common.extractYYYYMMDD(value.dateTime),
        'time': Common.extractTime(value.dateTime),
        'entry': value.entry,
        'amount': value.amount,
      },
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    return Journal.fromJson({
      ...value.toJson(),
      ...{'ID': id}
    });
  }
}

class MenuSQL extends RIUDRepository<Dish>
    with Readable<Dish>, Updatable<Dish>, Insertable<Dish>, Deletable<Dish> {
  final Database db;

  MenuSQL(this.db);

  @override
  Future<void> delete(Dish value) async {
    int c = await db.delete(dishTable, where: 'ID = ?', whereArgs: [value.id]);
    if (c == 0) {
      throw 'Unable to delete menu item as id ${value.id} does not exist';
    }
  }

  @override
  Future<List<Dish>> get([QueryKey? from, QueryKey? to]) async {
    List<Map<String, Object?>> menu;
    if (from == null && to == null) {
      menu = await db.query(dishTable);
    } else if (from != null && to == null) {
      menu = await db.query(dishTable, where: 'ID = ?', whereArgs: [from]);
    } else {
      menu = await db
          .query(dishTable, where: 'ID BETWEEN ? AND ?', whereArgs: [from, to]);
    }
    if (menu.isEmpty) {
      if (kDebugMode) print('\x1B[94mmenu not found in sqlite\x1B[0m');
      return [];
    }
    return (menu.map((e) => Dish.fromJson(e)).toList());
  }

  /// Upsert
  @override
  Future<Dish> insert(Dish value) async {
    final json = value.toJson()..remove('ID');
    final id = await db.insert(dishTable, json,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return Dish.fromJson({
      ...json,
      ...{'ID': id}
    });
  }

  @override
  Future<void> update(Dish value) async {
    final json = value.toJson()..remove('ID');
    final r = await db
        .update(dishTable, json, where: 'ID = ?', whereArgs: [value.id]);
    if (r <= 0) {
      throw 'Can not update a non-existing dish with ID = ${value.id}';
    }
  }
}

class NodeSQL extends RIUDRepository<Node>
    with Readable<Node>, Updatable<Node>, Insertable<Node>, Deletable<Node> {
  final Database db;

  NodeSQL(this.db);

  @override
  Future<void> delete(Node value) async {
    await db.delete(nodeTable, where: 'ID = ?', whereArgs: [value.id]);
  }

  @override
  Future<List<Node>> get([QueryKey? from, QueryKey? to]) async {
    List<Map<String, Object?>> nodes;
    if (from == null && to == null) {
      nodes = await db.query(nodeTable);
    } else if (from != null && to == null) {
      nodes = await db.query(nodeTable, where: 'ID = ?', whereArgs: [from]);
    } else {
      nodes = await db
          .query(nodeTable, where: 'ID BETWEEN ? AND ?', whereArgs: [from, to]);
    }
    return nodes.map<Node>((node) => Node.fromJson(node)).toList();
  }

  @override
  Future<Node> insert(Node value) async {
    final json = value.toJson()..remove('ID');
    final id = await db.insert(nodeTable, json,
        conflictAlgorithm: ConflictAlgorithm.fail);
    return Node.fromJson({
      ...value.toJson(),
      ...{'ID': id}
    });
  }

  @override
  Future<void> update(Node value) {
    return db.update(
      nodeTable,
      {
        'x': value.x,
        'y': value.y,
      },
      where: 'ID = ?',
      whereArgs: [value.id],
    );
  }
}
