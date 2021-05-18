import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../../storage_engines/connection_interface.dart';
import '../src.dart';

/// Second tab - report by line chart
class HistorySupplierByLine extends HistoryOrderSupplier {
  /// [['YYYY/MM/DD', value (after discount)]]
  List<List<dynamic>> groupedData = [];

  HistorySupplierByLine({OrderIO? database, DateTimeRange? range})
      : super(database: database, range: range) {
    _calGroupData();
  }

  HistorySupplierByLine update(HistorySupplierByDate firstTab) {
    selectedRange = firstTab.selectedRange;
    data = firstTab.data;
    _calGroupData();
    return this;
  }

  void _calGroupData() {
    groupedData = _groupByMonth(data);
  }

  List<List<dynamic>> _groupByMonth(List<Order> orders) {
    return orders.fold(
      [],
      (obj, o) {
        final time = Common.extractYYYYMMDD2(o.checkoutTime);
        final match = obj.firstWhere(
          (element) => element.isNotEmpty && element.first == time,
          orElse: () {
            final newObj = [time, 0];
            obj.add(newObj);
            return newObj;
          },
        );
        match[1] += (o.isDeleted == true ? 0 : o.totalPrice * o.discountRate);
        return obj;
      },
    );
  }
}
