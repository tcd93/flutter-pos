import 'dart:async';

import 'package:flutter/material.dart';
import '../../storage_engines/connection_interface.dart';

import '../src.dart';

class NodeSupplier extends ChangeNotifier {
  late List<Node> _nodes = [];
  List<Node> nodes(int page) {
    return List.unmodifiable(_nodes.where((node) => node.page == page));
  }

  Node? where(int id) {
    final n = _nodes.where((n) => n.id == id);
    return n.isNotEmpty ? n.first : null;
  }

  bool _loading = false;
  bool get loading => _loading;

  final RIUDRepository<Node>? database;

  NodeSupplier({
    this.database,
    List<Node>? mocks,
  }) {
    if (mocks != null) {
      _nodes = mocks;
      _loading = false;
      return;
    }
    _loading = true;
    Future(() async {
      _nodes = (await database?.get()) ?? [];
      _loading = false;
      notifyListeners();
    });
  }

  Future<int?> addNode(int page) async {
    final n = await database?.insert(Node(page: page));
    if (n != null) _nodes.add(n);
    notifyListeners();
    return n?.id;
  }

  Future<void> removeNode(Node node) async {
    assert(_nodes.contains(node));

    await database?.delete(node);
    _nodes.remove(node);
    notifyListeners();
    return;
  }

  void updateNode(Node node) {
    database?.update(node);
  }
}
