import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../provider/src.dart';
import 'journal_card.dart';

class ExpenseJournalList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final length = context.select((ExpenseSupplier provider) => provider.data.length);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: length,
      itemBuilder: (context, index) {
        return JournalCard(index);
      },
    );
  }
}
