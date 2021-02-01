import 'dart:async';

import 'package:flutter/material.dart';
import '../generated/l10n.dart';

Future<bool> popUpDelete(BuildContext context, {Widget title}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: title ?? Text(S.current.generic_deleteQuestion),
      actions: [
        TextButton(
          child: Text(S.current.generic_no),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text(S.current.generic_yes),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
}
