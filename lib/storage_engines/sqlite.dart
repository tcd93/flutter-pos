import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../common/common.dart';
import '../provider/src.dart';

const String orderTable = 'orders';
const String lineItemTable = 'lineItems';

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

class SQLite /*implements DatabaseConnectionInterface*/ {
  final String name;
  late final Database db;
  String? path;
  Map<String, dynamic>? initialData;

  SQLite(this.name, [this.path, this.initialData]);

  //---Order---

  @override
  Future<List<Order>> get(DateTime day) async {
    final rawResults = await db.rawQuery('''
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
    final rawResults = await db.query(
      orderTable,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [Common.extractYYYYMMDD(start), Common.extractYYYYMMDD(end)],
    );
    if (rawResults.isEmpty) {
      return [];
    }
    return mergeRaws(rawResults).map((i) => Order.fromJson(i)).toList();
  }

  @override
  Future<void> insert(Order order) {
    if (order.id < 0) throw 'Invalid order ID';

    return db.transaction((txn) async {
      final rowID = await txn.insert(
        orderTable,
        {
          'date': Common.extractYYYYMMDD(order.checkoutTime),
          'time': Common.extractTime(order.checkoutTime),
          'tableID': order.tableID,
          'status': order.status.index,
          'discountRate': order.discountRate,
          'isDeleted': order.isDeleted.toString(),
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
  Future<void> delete(DateTime day, int orderID) {
    return db.update(
      orderTable,
      {
        'isDeleted': true,
      },
      where: 'date = date(?) AND id = ?',
      whereArgs: [day, orderID],
    );
  }

  @override
  Future<bool> open() async {
    // use ffi for windows and linux as base sqflite package only work on mobile platform
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    if (kDebugMode) {
      print('Initiating sqlite database at path: ${await getDatabasesPath()}');
    }
    db = await openDatabase(
      join(path ?? await getDatabasesPath(), '$name.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
            CREATE TABLE $orderTable(
              ID           INTEGER PRIMARY KEY AUTOINCREMENT, 
              date         TEXT, -- YYYYMMDD
              time         TEXT, -- HH24:MM:SS
              tableID      INTEGER, 
              status       BOOLEAN,
              discountRate REAL,
              isDeleted    TINYINT
            );
            CREATE INDEX ${orderTable}Idx ON $orderTable (date, ID);

            CREATE TABLE $lineItemTable(
              orderID        INTEGER,
              dishID         INT,
              dishName       TEXT,
              price          REAL,
              quantity       INT,
              FOREIGN KEY(orderID) REFERENCES $orderTable(ID)
            );
          ''',
        );
      },
      version: 1,
    );
    return db.isOpen;
  }

  @override
  void close() => db.close();

  @override
  Future<void> destroy() => deleteDatabase(db.path);

//   //---Menu---

//   @override
//   Menu? getMenu() {
//     var storageData = ls.getItem('menu');
//     if (storageData == null) {
//       print('\x1B[94mmenu not found in localstorage\x1B[0m');
//       return null;
//     }
//     return Menu.fromJson(storageData as Map<String, dynamic>);
//   }

//   @override
//   Future<void> setMenu(Menu newMenu) {
//     // to set items to local storage
//     return ls.setItem('menu', newMenu);
//   }

// //---Node---

//   @override
//   Future<int> nextUID() async {
//     // if empty, starts from -1
//     int current = ls.getItem('order_id_highkey') ?? -1;
//     await ls.setItem('order_id_highkey', ++current);
//     return current;
//   }

//   @override
//   List<int> tableIDs() {
//     final List<dynamic> l = ls.getItem('table_list') ?? [];
//     return l.cast<int>();
//   }

//   @override
//   Future<List<int>> addTable(int tableID) async {
//     final list = tableIDs();
//     list.add(tableID);
//     await ls.setItem('table_list', list);
//     return list;
//   }

//   @override
//   Future<List<int>> removeTable(int tableID) async {
//     final list = tableIDs();
//     list.remove(tableID);
//     await ls.setItem('table_list', list);
//     return list;
//   }

//   @override
//   Future<void> setCoordinate(int tableID, double x, double y) {
//     return Future.wait(
//       [ls.setItem('${tableID}_coord_x', x), ls.setItem('${tableID}_coord_y', y)],
//       eagerError: true,
//     );
//   }

//   @override
//   double getX(int tableID) {
//     return ls.getItem('${tableID}_coord_x') ?? 0;
//   }

//   @override
//   double getY(int tableID) {
//     return ls.getItem('${tableID}_coord_y') ?? 0;
//   }

//   //---Journal---

//   @override
//   List<Journal> getJournal(DateTime day) {
//     List<dynamic>? storageData = ls.getItem('j${Common.extractYYYYMMDD(day)}');
//     if (storageData == null) return [];
//     return storageData.map((i) => Journal.fromJson(i)).toList();
//   }

//   @override
//   List<Journal> getJournals(DateTime start, DateTime end) {
//     return List.generate(
//       end.difference(start).inDays + 1,
//       (i) => getJournal(DateTime(start.year, start.month, start.day + i)),
//     ).expand((e) => e).toList();
//   }

//   @override
//   Future<void> insertJournal(Journal journal) {
//     if (journal.id < 0) throw 'Invalid order ID';
//     final dateTime = Common.extractYYYYMMDD(journal.dateTime);

//     var journals = ls.getItem('j$dateTime');
//     if (journals != null) {
//       journals.add(journal.toJson());
//     } else {
//       journals = [journal.toJson()];
//     }
//     return ls.setItem('j$dateTime', journals);
//   }
}
