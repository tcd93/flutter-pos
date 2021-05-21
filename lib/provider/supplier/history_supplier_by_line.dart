import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../../storage_engines/connection_interface.dart';
import '../src.dart';

/// Second tab - report by line chart
class HistorySupplierByLine extends HistoryOrderSupplier {
  /// If ranges over multiple days, then group by day: [['YYYY/MM/DD', value]].
  /// If ranges over one day, the group by time: [['HH24:MM', value]]
  List<List<dynamic>> groupedData = [];

  HistorySupplierByLine({OrderIO? database, DateTimeRange? range})
      : super(database: database, range: range) {
    groupedData = _group(data);
  }

  HistorySupplierByLine update(HistorySupplierByDate firstTab) {
    selectedRange = firstTab.selectedRange;
    data = firstTab.data;
    discountFlag = firstTab.discountFlag;
    groupedData = _group(data);
    return this;
  }

  String extractTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}'
        ':'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Returns a list of [groupedData], the outer list is for indexing the X axis (time).
  /// The nested inner list is for marking the display titles and values
  List<List<dynamic>> _group(List<Order> orders) {
    return orders.fold(
      [],
      (obj, o) {
        String xAxis;
        if (selectedRange.duration.inDays > 1) {
          xAxis = Common.extractYYYYMMDD2(o.checkoutTime);
        } else {
          xAxis = extractTime(o.checkoutTime);
        }
        final match = obj.firstWhere(
          (element) => element.isNotEmpty && element.first == xAxis,
          orElse: () {
            final newObj = [xAxis, 0];
            obj.add(newObj);
            return newObj;
          },
        );
        match[1] += saleAmountOf(o);
        return obj;
      },
    );
  }
}
