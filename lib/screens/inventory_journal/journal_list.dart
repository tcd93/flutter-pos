import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../provider/src.dart';
import 'journal_card.dart';

class InventoryJournalList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = context.select((InventorySupplier provider) => provider.data);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return JournalCard(index);
      },
    );
  }
}
