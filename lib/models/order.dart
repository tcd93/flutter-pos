// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

enum Status { Ongoing, Empty }

class OrderTracker {
  final List<TableModel> _tables =
      List.generate(7, (index) => TableModel(index), growable: false);

  TableModel getTable(int index) => _tables[index];
}

class TableModel {
  final int id;
  Status status;

  TableModel(this.id) : status = Status.Empty;

  Color getStatusColor() =>
      this.status == Status.Empty ? Colors.green[400] : Colors.grey[600];
}
