import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../common/common.dart';
import '../../provider/src.dart';

class AddNewEntryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final exSupplier = context.read<ExpenseSupplier>();
        final j = await _popUpNewJournal(context);
        if (j != null) {
          exSupplier.addJournal(j);
        }
      },
      child: const Icon(Icons.add),
    );
  }
}

Future<Journal?> _popUpNewJournal(BuildContext scaffoldCtx) {
  final t = TextEditingController();
  final m = TextEditingController(text: '0');
  var d = DateTime.now();
  final dc = TextEditingController(text: Common.extractYYYYMMDD2(d));
  return showDialog<Journal?>(
    context: scaffoldCtx,
    builder: (context) {
      final formKey = GlobalKey<FormState>();
      return AlertDialog(
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: t,
                textAlign: TextAlign.center,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.journal_entry,
                  hintText: AppLocalizations.of(context)!.journal_entryHint,
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? AppLocalizations.of(context)!.journal_entryReqTxt
                    : null,
              ),
              TextFormField(
                controller: m,
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                inputFormatters: [MoneyFormatter()],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.journal_amt,
                  suffixText: Money.symbol,
                ),
              ),
              TextFormField(
                controller: dc,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.journal_datetime,
                ),
                onTap: () async {
                  // Stop keyboard from appearing
                  FocusScope.of(context).requestFocus(FocusNode());
                  d = await showDatePicker(
                        context: context,
                        fieldLabelText: AppLocalizations.of(context)!.journal_datetime,
                        initialDate: d,
                        firstDate: DateTime(2019),
                        lastDate: DateTime.now(),
                      ) ??
                      DateTime.now();
                  dc.text = Common.extractYYYYMMDD2(d);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final p = Money.unformat(m.text);
                Navigator.pop<Journal>(
                  context,
                  Journal(entry: t.text, entryTime: d, amount: p.toDouble()),
                );
              }
            },
            child: const Icon(Icons.check),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(Icons.cancel),
          ),
        ],
      );
    },
  );
}
