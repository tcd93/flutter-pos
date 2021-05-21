import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/common.dart';
import '../../provider/src.dart';
import 'first_tab/order_list.dart';
import 'second_tab/order_linechart.dart';
import 'date_picker.dart';

// heavy usage of Listenable objects to gain finer controls over widget rebuilding scope.

@immutable
class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _LeadingTitle(),
        bottomOpacity: 0.5,
        bottom: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.list_alt_rounded)),
            Tab(icon: Icon(Icons.show_chart)),
          ],
        ),
        actions: [
          Column(
            children: [
              Switch.adaptive(
                value: context.select((HistorySupplierByDate s) => s.discountFlag),
                onChanged: (s) => context.read<HistorySupplierByDate>().discountFlag = s,
              ),
              Text(
                AppLocalizations.of(context)?.history_toggleDiscount ?? 'Apply Discount Rate',
                style: Theme.of(context).textTheme.caption?.apply(fontSizeFactor: 0.5),
              ),
            ],
          ),

          // fix the text size of the "current date"
          Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.copyWith(
                    bodyText1: GoogleFonts.eczar(fontSize: 20),
                  ),
            ),
            child: DatePicker(),
          ),
        ],
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HistoryOrderList(),
          HistoryOrderLineChart(),
        ],
      ),
    );
  }
}

class _LeadingTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistorySupplierByDate>(context);
    final price = provider.sumAmount;
    final range = provider.selectedRange;
    return Wrap(
      direction: Axis.vertical,
      children: [
        Text(
          '${Money.format(price)}',
          style: TextStyle(
            color: Colors.lightGreen,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        Text(
          '(${Common.extractYYYYMMDD2(range.start)} - ${Common.extractYYYYMMDD2(range.end)})',
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }
}
