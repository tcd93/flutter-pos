import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart' as lib;

import '../../common/common.dart';
import '../../provider/src.dart';
import '../connection_interface.dart';

part 'mixins.dart';

class LocalStorage implements DatabaseConnectionInterface {
  final lib.LocalStorage ls;

  LocalStorage(String name, [String? path, JsonMap? initialData])
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
}

class OrderLS extends RIDRepository<Order>
    with _ReadableImpl<Order>, _InsertableImpl<Order>
    implements Deletable<Order> {
  final lib.LocalStorage _ls;
  OrderLS(this._ls);

  /// soft-delete by marking [Order.isDeleted] = true
  @override
  Future<void> delete(Order value) async {
    final key = _getKeyFromObject(value);
    final List<Order> orders = await get(key);
    await ls.setItem(
        _getKeyString(key),
        orders.map((e) {
          if (_getKeyFromObject(e).compareTo(key) == 0) {
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

class NodeLS extends RIUDRepository<Node>
    with _ReadableImpl<Node>, _UpdatableImpl<Node>, _InsertableImpl<Node>, _DeletableImpl<Node> {
  final lib.LocalStorage _ls;

  @override
  String get fixedKeyString => 'node';

  NodeLS(this._ls);

  @override
  lib.LocalStorage get ls => _ls;

  @override
  String get _idHighkey => 'node_id_highkey';

  @override
  int _getKeyFromObject(value) => value.id;
}

class ConfigLS extends RIUDRepository<Config>
    with
        _ReadableImpl<Config>,
        _UpdatableImpl<Config>,
        _InsertableImpl<Config>,
        _DeletableImpl<Config> {
  final lib.LocalStorage _ls;

  @override
  String get fixedKeyString => 'config';

  ConfigLS(this._ls);

  @override
  lib.LocalStorage get ls => _ls;

  @override
  String get _idHighkey => 'config_id_highkey';

  @override
  String _getKeyFromObject(value) => value.key;
}
