import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/common.dart';
import '../../provider/src.dart';
import '../date_picker.dart';
import 'journal_list.dart';
import 'add_new_entry_button.dart';

class ExpenseJournalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _LeadingTitle(),
        bottomOpacity: 0.5,
        actions: [
          // fix the text size of the "current date"
          Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.copyWith(
                    bodyLarge: GoogleFonts.eczar(fontSize: 20),
                  ),
            ),
            child: DatePicker<ExpenseSupplier>(),
          ),
        ],
      ),
      body: Selector<ExpenseSupplier, bool>(
        selector: (context, supplier) => supplier.loading,
        builder: (context, loading, _) {
          if (loading) {
            return const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            );
          }

          final List<Journal> journals = context.read<ExpenseSupplier>().data;
          if (journals.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)?.generic_empty ?? 'No data found'),
            );
          } else {
            return ExpenseJournalList();
          }
        },
      ),
      floatingActionButton: AddNewEntryButton(),
    );
  }
}

class _LeadingTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseSupplier>(context);
    final price = provider.sumAmount;
    final range = provider.selectedRange;
    return Wrap(
      direction: Axis.vertical,
      children: [
        Text(
          Money.format(price),
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
