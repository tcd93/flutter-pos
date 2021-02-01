import 'package:date_range_picker/date_range_picker.dart' as date_range_picker;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DatePicker extends StatelessWidget {
  final ValueNotifier<DateTimeRange> range;

  DatePicker(this.range);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Icon(Icons.date_range),
      onPressed: () async {
        final dates = await date_range_picker.showDatePicker(
          context: context,
          initialFirstDate: range.value.start.add(Duration(days: -30)),
          initialLastDate: range.value.end,
          firstDate: DateTime(2019),
          lastDate: DateTime.now(),
        );
        if (dates != null && dates.isNotEmpty) {
          final selectedRange = DateTimeRange(start: dates.first, end: dates.last);
          if (selectedRange.duration.compareTo(range.value.duration) != 0) {
            range.value = selectedRange;
          }
        }
      },
    );
  }
}
