import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/common.dart';

class FormContent extends StatelessWidget {
  final Widget? avatar;
  final List<TextField> inputs;
  final VoidCallback onSubmit;
  final VoidCallback? onCancel;

  /// the gap between inputs
  final double gap;
  final double buttonMinWidth;

  FormContent({
    required this.inputs,
    required this.onSubmit,
    this.onCancel,
    this.avatar,
    this.gap = 25.0,
    this.buttonMinWidth = 150.0,
  });

  @override
  Widget build(BuildContext context) {
    // wraps [Column] inside [SingleChildScrollView] under [AnimatedContainer]
    // to prevents RenderFlex overflowed errors...
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              if (avatar != null)
                Expanded(
                  flex: 1,
                  child: Column(children: [avatar!]),
                ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ...inputs.expand(
                      (t) => [t, SizedBox(height: gap)],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: gap), // additional gap to button
          ButtonBar(
            children: [
              if (onCancel != null)
                TextButton(
                  child: Text(AppLocalizations.of(context)!.generic_cancel.toUpperCase()),
                  onPressed: onCancel,
                ),
              ElevatedButton(
                child: Text(AppLocalizations.of(context)!.generic_confirm.toUpperCase()),
                onPressed: onSubmit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<TextField> buildInputs(
  BuildContext context,
  TextEditingController dishNameController,
  TextEditingController priceController, [
  TextAlign align = TextAlign.center,
]) {
  return [
    TextField(
      controller: dishNameController,
      keyboardType: TextInputType.text,
      textAlign: align,
      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.edit_menu_formLabel),
    ),
    TextField(
      controller: priceController,
      keyboardType: TextInputType.number,
      textAlign: align,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.edit_menu_formPrice,
        suffix: Text(Money.symbol),
      ),
      inputFormatters: [MoneyFormatter()],
    ),
  ];
}
