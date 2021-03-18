import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../common/common.dart';
import '../../provider/src.dart';
import '../../provider/supplier/inventory_journal_supplier.dart';

class AddNewEntryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final j = await _popUpNewJournal(context);
        if (j != null) {
          context.read<InventorySupplier>().add(j);
        }
      },
      child: Icon(Icons.add),
    );
  }
}

// TODO complete this skeleton
Future<Journal?> _popUpNewJournal(BuildContext scaffoldCtx) {
  final t = TextEditingController();
  return showDialog<Journal?>(
    context: scaffoldCtx,
    builder: (context) {
      return AlertDialog(
        content: TextField(
          controller: t,
          keyboardType: TextInputType.numberWithOptions(signed: true),
          inputFormatters: [MoneyFormatter()],
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.details_customerPay,
            suffixText: Money.symbol,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final p = Money.unformat(t.text);
              Navigator.pop<Journal>(context, Journal(id: 100, amount: p.toDouble()));
            },
            child: Icon(Icons.check),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(Icons.cancel),
          ),
        ],
      );
    },
  );
}
