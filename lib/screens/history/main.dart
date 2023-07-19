import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/common.dart';
import '../../provider/src.dart';
import 'first_tab/order_list.dart';
import 'second_tab/order_linechart.dart';
import '../date_picker.dart';

@immutable
class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _LeadingTitle(),
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
              Selector<HistoryOrderSupplier, bool>(
                selector: (context, supplier) => supplier.discountFlag,
                builder: (context, flag, _) {
                  return Switch.adaptive(
                    value: context.select((HistoryOrderSupplier s) => s.discountFlag),
                    onChanged: (s) => context.read<HistoryOrderSupplier>().discountFlag = s,
                  );
                },
              ),
              Text(
                AppLocalizations.of(context)?.history_toggleDiscount ?? 'Apply Discount Rate',
                style: Theme.of(context).textTheme.bodySmall?.apply(fontSizeFactor: 0.5),
              ),
            ],
          ),

          // fix the text size of the "current date"
          Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.copyWith(
                    bodyLarge: GoogleFonts.eczar(fontSize: 20),
                  ),
            ),
            child: DatePicker<HistoryOrderSupplier>(),
          ),
        ],
      ),
      body: Selector<HistoryOrderSupplier, bool>(
        selector: (context, supplier) => supplier.loading,
        builder: (context, loading, _) {
          final List<Order> orders = context.read<HistoryOrderSupplier>().orders;
          if (loading) {
            return const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            );
          }
          if (orders.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)?.generic_empty ?? 'No data found'),
            );
          } else {
            return TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                HistoryOrderList(),
                HistoryOrderLineChart(),
              ],
            );
          }
        },
      ),
    );
  }
}

class _LeadingTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistoryOrderSupplier>(context);
    final range = provider.selectedRange;
    final orders = context.select((HistoryOrderSupplier supplier) => supplier.orders);

    return Wrap(
      direction: Axis.vertical,
      children: [
        Text(
          Money.format(provider.calculateTotalSalesAmount(orders)),
          style: const TextStyle(
            color: Colors.lightGreen,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        Text(
          '(${Common.extractYYYYMMDD2(range.start)} - ${Common.extractYYYYMMDD2(range.end)})',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
