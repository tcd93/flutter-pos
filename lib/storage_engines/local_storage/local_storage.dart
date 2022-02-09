import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart' as lib;

import '../../common/common.dart';
import '../../provider/src.dart';
import '../connection_interface.dart';

part 'mixins.dart';

class LocalStorage implements DatabaseConnectionInterface {
  final lib.LocalStorage ls;

  LocalStorage(String name, [String? path, _JsonMap? initialData])
      : ls = lib.LocalStorage(name, path, initialData);

  @override
  Future<bool> open() => ls.ready;

  @override
  Future<void> close() async {
    ls.dispose();
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> destroy() => ls.clear();

  @override
  Future<void> truncate() => ls.clear();

//---Node---

  @override
  Future<List<int>> tableIDs() async {
    final List<dynamic> l = ls.getItem('table_list') ?? [];
    return l.cast<int>();
  }

  @override
  Future<int> addTable() async {
    final list = await tableIDs();
    final nextID = list.fold<int>(0, max) + 1;
    list.add(nextID);
    await ls.setItem('table_list', list);
    return nextID;
  }

  @override
  Future<void> removeTable(int tableID) async {
    final list = await tableIDs();
    list.remove(tableID);
    await ls.setItem('table_list', list);
    return;
  }

  @override
  Future<void> setCoordinate(int tableID, double x, double y) {
    return Future.wait(
      [ls.setItem('${tableID}_coord_x', x), ls.setItem('${tableID}_coord_y', y)],
      eagerError: true,
    );
  }

  @override
  Future<double> getX(int tableID) async {
    return ls.getItem('${tableID}_coord_x') ?? 0;
  }

  @override
  Future<double> getY(int tableID) async {
    return ls.getItem('${tableID}_coord_y') ?? 0;
  }
}

class OrderLS extends RIDRepository<Order>
    with _ReadableImpl<Order>, _InsertableImpl<Order>
    implements Deletable<Order> {
  final lib.LocalStorage _ls;
  OrderLS(this._ls);

  /// soft-delete by marking [Order.isDeleted] = true
  @override
  Future<void> delete(Order value) async {
    final _key = _getKeyFromObject(value);
    final List<Order> orders = await get(_key);
    await ls.setItem(
        _getKeyString(_key),
        orders.map((e) {
          if (_getKeyFromObject(e).compareTo(_key) == 0) {
            return {
              ...e.toJson(),
              ...{'isDeleted': true}
            };
          }
          return e.toJson();
        }).toList());
    return;
  }

  @override
  lib.LocalStorage get ls => _ls;

  @override
  String get _idHighkey => 'order_id_highkey';

  @override
  String _getKeyString(QueryKey key) {
    assert(key is DateTime);
    return Common.extractYYYYMMDD(key as DateTime);
  }

  @override
  DateTime _getKeyFromObject(Order value) => value.checkoutTime;
}

class JournalLS extends RIRepository<Journal>
    with _ReadableImpl<Journal>, _InsertableImpl<Journal> {
  final lib.LocalStorage _ls;
  JournalLS(this._ls);

  @override
  lib.LocalStorage get ls => _ls;

  @override
  String get _idHighkey => 'journal_id_highkey';

  @override
  String _getKeyString(QueryKey key) {
    assert(key is DateTime);
    return 'j${Common.extractYYYYMMDD(key as DateTime)}';
  }

  @override
  DateTime _getKeyFromObject(Journal value) => value.dateTime;
}

class MenuLS extends RIUDRepository<Dish>
    with _ReadableImpl<Dish>, _UpdatableImpl<Dish>, _InsertableImpl<Dish>, _DeletableImpl<Dish> {
  final lib.LocalStorage _ls;

  @override
  String get fixedKeyString => 'menu';

  MenuLS(this._ls);

  @override
  lib.LocalStorage get ls => _ls;

  @override
  String get _idHighkey => 'dish_id_highkey';

  @override
  int _getKeyFromObject(value) => value.id;
}
