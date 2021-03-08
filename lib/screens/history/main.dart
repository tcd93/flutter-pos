import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common/common.dart';
import '../../storage_engines/connection_interface.dart';
import './order_list.dart';
import 'date_picker.dart';

// heavy usage of Listenable objects to gain finer controls over widget rebuilding scope.

@immutable
class HistoryScreen extends StatelessWidget {
  final DatabaseConnectionInterface database;
  final ValueNotifier<DateTimeRange> range;
  final ValueNotifier<double> amount;

  HistoryScreen(this.database, [DateTime? from, DateTime? to])
      : range = ValueNotifier(
          DateTimeRange(start: from ?? DateTime.now(), end: to ?? DateTime.now()),
        ),
        amount = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _LeadingTitle(
          displayRange: range,
          summaryPrice: amount,
        ),
        bottomOpacity: 0.5,
        actions: [
          // fix the text size of the "current date"
          Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.copyWith(
                    bodyText1: GoogleFonts.eczar(fontSize: 20),
                  ),
            ),
            child: DatePicker(range),
          ),
        ],
      ),
      body: HistoryOrderList(database, range, amount),
    );
  }
}

class _LeadingTitle extends StatelessWidget {
  final ValueListenable<DateTimeRange> displayRange;
  final ValueListenable<double> summaryPrice;

  _LeadingTitle({required this.displayRange, required this.summaryPrice});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.vertical,
      children: [
        ValueListenableBuilder<double>(
          valueListenable: summaryPrice,
          builder: (_, price, __) {
            return Text(
              '${Money.format(price)}',
              style: TextStyle(
                color: Colors.lightGreen,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            );
          },
        ),
        ValueListenableBuilder<DateTimeRange>(
          valueListenable: displayRange,
          builder: (_, range, __) => Text(
            '(${Common.extractYYYYMMDD2(range.start)} - ${Common.extractYYYYMMDD2(range.end)})',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ],
    );
  }
}
