import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../common/common.dart';
import '../provider/src.dart';
import 'connection_interface.dart';

const String nodeTable = 'nodes';
const String orderTable = 'orders';
const String lineItemTable = 'lineItems';
const String dishTable = 'dish';

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
          'checkoutTime': (element['date']! as String) + ' ' + (element['time']! as String),
          'tableID': element['tableID'],
          'status': element['status'],
          'discountRate': element['discountRate'],
          'isDeleted': element['isDeleted'],
          'lineItems': [
            {
              'orderID': element['orderID'],
              'dishID': element['dishID'],
              'dishName': element['dishName'],
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
        'dishName': element['dishName'],
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
  late Database _db;
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
      final _dtb = await openDatabase(
        join(path ?? await getDatabasesPath(), '$name.db'),
        onCreate: (db, version) {
          return db.execute(
            '''
            CREATE TABLE $nodeTable(
              ID           INTEGER PRIMARY KEY AUTOINCREMENT, 
              coordX       REAL DEFAULT 0,
              coordY       REAL DEFAULT 0
            );

            CREATE TABLE $orderTable(
              ID           INTEGER PRIMARY KEY AUTOINCREMENT, 
              date         TEXT, -- YYYYMMDD
              time         TEXT, -- HH24:MM:SS
              tableID      INTEGER, 
              status       TINYINT,
              discountRate REAL,
              isDeleted    BOOLEAN
            );
            CREATE INDEX ${orderTable}Idx ON $orderTable (date, ID);

            CREATE TABLE $dishTable(
              ID             INTEGER PRIMARY KEY AUTOINCREMENT, 
              price          REAL,
              dish           TEXT,
              imageBytes     BLOB,
              asset          TEXT
            );

            CREATE TABLE $lineItemTable(
              orderID        INTEGER,
              dishID         INT,
              dishName       TEXT,
              price          REAL,
              quantity       INT,
              FOREIGN KEY(orderID) REFERENCES $orderTable(ID),
              FOREIGN KEY(dishID) REFERENCES $dishTable(ID)
            );
            CREATE INDEX ${lineItemTable}Idx ON $lineItemTable (orderID);
            ''',
          );
        },
        version: 1,
      );
      if (kDebugMode) {
        print('Initiating sqlite database at path: ${await getDatabasesPath()}');
      }
      _db = _dtb;
      _completer.complete(_dtb.isOpen);
    });
  }

  @override
  Future<void> truncate() {
    if (_db.isOpen) {
      return _db.execute('''
        DELETE FROM $orderTable;
        DELETE FROM $lineItemTable;
        DELETE FROM $dishTable;
        DELETE FROM $nodeTable;
        DELETE FROM sqlite_sequence WHERE name='$orderTable';
        DELETE FROM sqlite_sequence WHERE name='$lineItemTable';
        DELETE FROM sqlite_sequence WHERE name='$dishTable';
        DELETE FROM sqlite_sequence WHERE name='$nodeTable';
      ''');
    }
    throw 'Database is not opened';
  }

  //---Order---

  @override
  Future<List<Order>> get(DateTime day) async {
    final rawResults = await _db.rawQuery('''
      SELECT *
        FROM $orderTable o
        JOIN $lineItemTable l
          ON o.ID = l.orderID
       WHERE o.date = ?
       ORDER BY o.ID
    ''', [Common.extractYYYYMMDD(day)]);

    if (rawResults.isEmpty) {
      return [];
    }
    return mergeRaws(rawResults).map((i) => Order.fromJson(i)).toList();
  }

  @override
  Future<List<Order>> getRange(DateTime start, DateTime end) async {
    final rawResults = await _db.rawQuery('''
      SELECT *
        FROM $orderTable o
        JOIN $lineItemTable l
          ON o.ID = l.orderID
       WHERE o.date BETWEEN ? AND ?
       ORDER BY o.ID
    ''', [Common.extractYYYYMMDD(start), Common.extractYYYYMMDD(end)]);

    if (rawResults.isEmpty) {
      return [];
    }
    return mergeRaws(rawResults).map((i) => Order.fromJson(i)).toList();
  }

  @override
  Future<void> insert(Order order) {
    return _db.transaction((txn) async {
      final rowID = await txn.insert(
        orderTable,
        {
          'date': Common.extractYYYYMMDD(order.checkoutTime),
          'time': Common.extractTime(order.checkoutTime),
          'tableID': order.tableID,
          'status': order.status.index,
          'discountRate': order.discountRate,
          'isDeleted': order.isDeleted ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );

      if (rowID == 0) {
        return;
      }

      final lastOrderID = (await txn.query(
        orderTable,
        where: 'rowid = ?',
        whereArgs: [rowID],
      ))
          .first
          .values
          .first;

      final batch = txn.batch();
      for (final li in order.lineItems) {
        batch.insert(
          lineItemTable,
          {
            'orderID': lastOrderID,
            'dishID': li.dishID,
            'dishName': li.dishName,
            'price': li.price,
            'quantity': li.quantity,
          },
          conflictAlgorithm: ConflictAlgorithm.fail,
        );
      }
      await batch.commit(noResult: true);
      return;
    });
  }

  @override
  Future<int> delete(DateTime day, int orderID) {
    return _db.update(
      orderTable,
      {
        'isDeleted': 1,
      },
      where: 'date = ? AND id = ?',
      whereArgs: [Common.extractYYYYMMDD(day), orderID],
    );
  }

  @override
  Future<bool> open() => _completer.future;

  @override
  Future<void> close() => _db.close();

  @override
  Future<void> destroy() => deleteDatabase(_db.path);

  //Menu (the entire thing is pretty hacky here as it adapts to key-value storage's find & replace
  //style of execution)

  @override
  Future<Menu?> getMenu() async {
    var menu = await _db.query(dishTable);
    if (menu.isEmpty) {
      if (kDebugMode) print('\x1B[94mmenu not found in sqlite\x1B[0m');
      return null;
    }
    return Menu.fromJson({'list': menu.map((d) => Dish.fromJson(d)).toList()});
  }

  @override
  Future<void> setMenu({Menu? menu, Dish? dish, bool isDelete = false}) async {
    if (dish == null) throw '[SQLite] setMenu() is only supported with `dish` parameter';
    if (!isDelete) {
      // upsert
      await _db.insert(dishTable, dish.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      int c = await _db.delete(dishTable, where: 'ID = ?', whereArgs: [dish.id]);
      if (c == 0) {
        throw 'Unable to delete menu item as id ${dish.id} does not exist';
      }
    }
    return;
  }

//---Node---

  @override
  Future<List<int>> tableIDs() async {
    var idMap = await _db.query(nodeTable, columns: ['ID']);
    return idMap.map<int>((m) => m['ID'] as int).toList();
  }

  @override
  Future<int> addTable() {
    return _db.insert(
      nodeTable,
      {},
      nullColumnHack: 'coordX',
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  @override
  Future<void> removeTable(int tableID) async {
    await _db.delete(nodeTable, where: 'ID = ?', whereArgs: [tableID]);
  }

  @override
  Future<void> setCoordinate(int tableID, double x, double y) async {
    return;
  }

  @override
  double getX(int tableID) {
    return 0;
  }

  @override
  double getY(int tableID) {
    return 0;
  }

  //---Journal---

  @override
  List<Journal> getJournal(DateTime day) {
    return [];
  }

  @override
  List<Journal> getJournals(DateTime start, DateTime end) {
    return [];
  }

  @override
  Future<void> insertJournal(Journal journal) async {
    return;
  }
}
