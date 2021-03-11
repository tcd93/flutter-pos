import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Future<bool?> popUpDelete(BuildContext context, {Widget? title}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: title ?? Text(AppLocalizations.of(context)!.generic_deleteQuestion),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context)!.generic_no),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(AppLocalizations.of(context)!.generic_yes),
        ),
      ],
    ),
  );
}
