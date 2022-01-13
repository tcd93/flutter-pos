import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/common.dart';
import '../../provider/src.dart';
import 'first_tab/order_list.dart';
import 'second_tab/order_linechart.dart';
import 'date_picker.dart';

@immutable
class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final future = context.select(
      (HistorySupplierByDate provider) => provider.retrieveOrders(),
    );

    return Scaffold(
      appBar: AppBar(
        title: _LeadingTitle(future),
        bottomOpacity: 0.5,
        bottom: const TabBar(
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
      body: FutureBuilder(
        future: future,
        builder: (_, AsyncSnapshot<Iterable<Order>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  HistoryOrderList(snapshot.data!),
                  HistoryOrderLineChart(snapshot.data!),
                ],
              );
            } else {
              return Center(
                child: Text(AppLocalizations.of(context)?.generic_empty ?? 'No data found'),
              );
            }
          } else {
            return const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            );
          }
        },
      ),
    );
  }
}

class _LeadingTitle extends StatelessWidget {
  final Future<Iterable<Order>> future;

  const _LeadingTitle(this.future);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistorySupplierByDate>(context);
    final range = provider.selectedRange;

    return FutureBuilder(
      future: future,
      builder: (_, AsyncSnapshot<Iterable<Order>> snapshot) {
        return Wrap(
          direction: Axis.vertical,
          children: [
            if (snapshot.data != null && snapshot.data!.isNotEmpty)
              Text(
                Money.format(provider.calculateTotalSalesAmount(snapshot.data!)),
                style: const TextStyle(
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
      },
    );
  }
}
