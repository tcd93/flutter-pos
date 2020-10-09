// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';

class LobbyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catalog', style: Theme.of(context).textTheme.headline1),
      ),
      body: _LobbyLayout(),
    );
  }
}

/// Represents the table layout in lobby: 4 at the right side, 3 at the left side
class _LobbyLayout extends StatelessWidget {
  _LobbyLayout({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var textTheme = Theme.of(context).textTheme.headline6;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Table(1),
            _Table(2),
          ],
        ),
      ],
    );
  }
}

class _Table extends StatelessWidget {
  final int id;

  _Table(this.id);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        height: 100,
        width: 100,
        child: Container(
          color: context.select<OrderTracker, Color>(
              (tracker) => tracker.getTable(this.id).getStatusColor()),
        ),
      ),
    );
  }
}
