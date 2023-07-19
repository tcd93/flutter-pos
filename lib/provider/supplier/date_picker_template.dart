import 'package:flutter/material.dart';

abstract class DatePickerTemplate {
  DateTimeRange get selectedRange;
  set selectedRange(DateTimeRange newRange);
}
