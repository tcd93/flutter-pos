import 'package:date_range_picker/date_range_picker.dart' as date_range_picker;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../provider/src.dart';

class DatePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Icon(Icons.date_range),
      onPressed: () async {
        final provider = context.read<HistorySupplierByDate>();
        final range = provider.selectedRange;
        final dates = await date_range_picker.showDatePicker(
          context: context,
          initialFirstDate: range.start,
          initialLastDate: range.end,
          firstDate: DateTime(2019),
          lastDate: DateTime.now(),
        );
        if (dates != null && dates.isNotEmpty) {
          final newlySelectedRange = DateTimeRange(start: dates.first, end: dates.last);
          provider.selectedRange = newlySelectedRange;
        }
      },
    );
  }
}
