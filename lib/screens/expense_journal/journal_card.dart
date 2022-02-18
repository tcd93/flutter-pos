import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/common.dart';
import '../../provider/src.dart';

class JournalCard extends StatelessWidget {
  final int index;

  const JournalCard(this.index);

  @override
  Widget build(BuildContext context) {
    var journal = context.select<ExpenseSupplier, Journal?>(
      (ExpenseSupplier supplier) =>
          (index < supplier.data.length) ? supplier.data.elementAt(index) : null,
    );
    if (journal == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.center,
      widthFactor: 0.95,
      child: Card(
        key: ObjectKey(journal),
        child: ListTile(
          leading: CircleAvatar(child: Text(journal.id.toString())),
          title: Text(journal.entry, overflow: TextOverflow.ellipsis, textScaleFactor: 0.85),
          subtitle: Text(Common.extractYYYYMMDD3(journal.dateTime)),
          trailing: Text(
            Money.format(journal.amount),
            style: const TextStyle(
              letterSpacing: 3,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
