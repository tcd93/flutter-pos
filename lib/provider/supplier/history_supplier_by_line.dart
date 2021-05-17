import 'package:flutter/material.dart';

import '../../storage_engines/connection_interface.dart';
import '../src.dart';

/// Second tab - report by line chart
class HistorySupplierByLine extends HistoryOrderSupplier {
  HistorySupplierByLine({OrderIO? database, DateTimeRange? range})
      : super(database: database, range: range);
}
