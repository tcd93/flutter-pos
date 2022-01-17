import 'package:flutter/foundation.dart';

import '../src.dart';

@immutable
class LineItemList extends Iterable<LineItem> {
  final List<LineItem> _list;

  LineItemList([Iterable<LineItem>? fromList]) : _list = fromList?.toList() ?? [];

  LineItemList.copy(LineItemList other)
      : _list = other
            .map((e) => LineItem(associatedDish: e.associatedDish, quantity: e.quantity))
            .toList(); // clone a list

  void add(LineItem item) => _list.add(item);

  LineItemList.fromJson(List<dynamic> json)
      : _list = json.map((d) => LineItem.fromJson(d)).toList();

  List<dynamic> toJson() => _list.map((e) => e.toJson()).toList();

  @override
  String toString() => toJson().toString();

  @override
  Iterator<LineItem> get iterator => _list.iterator;
}
