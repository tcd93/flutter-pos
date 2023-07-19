import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/src.dart';

class DatePicker<T extends DatePickerTemplate> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final provider = context.read<T>();
        final range = provider.selectedRange;

        final value = await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                    content: SizedBox(
                  height: 450,
                  width: 350,
                  child: getDateRangePicker(context, range),
                )));

        if (value is PickerDateRange && value.startDate != null && value.endDate != null) {
          provider.selectedRange = DateTimeRange(start: value.startDate!, end: value.endDate!);
        }
      },
      child: const Icon(Icons.date_range),
    );
  }

  Widget getDateRangePicker(BuildContext context, DateTimeRange initialRange) => SfDateRangePicker(
        view: DateRangePickerView.month,
        selectionMode: DateRangePickerSelectionMode.range,
        initialSelectedDates: [
          initialRange.start,
          initialRange.end,
        ],
        showActionButtons: true,
        onSubmit: (value) => Navigator.pop(context, value),
        onCancel: () => Navigator.pop(context),
      );
}
