import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/common.dart' show Money, MoneyFormatter, NumberEL100Formatter;
import '../../theme/rally.dart';
import '../../provider/src.dart' show Supplier, TableModel;

class BottomNavBar extends StatelessWidget {
  final String fromScreen;
  final String? fromHeroTag;
  final TableModel order;

  BottomNavBar(this.order, {required this.fromScreen, this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: fromScreen != 'history'
            ? [
                _ApplyDiscountButton(
                  order,
                  fromScreen: fromScreen,
                ),
                _CheckoutButton(
                  order,
                  fromHeroTag: fromHeroTag,
                  fromScreen: fromScreen,
                ),
              ]
            : [
                const SizedBox(height: bottomNavbarHeight), // dummy
                const SizedBox(height: bottomNavbarHeight),
              ],
      ),
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  final TableModel order;
  final String? fromHeroTag;
  final String fromScreen;

  _CheckoutButton(this.order, {this.fromHeroTag, required this.fromScreen});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: fromHeroTag ?? 'CheckoutButtonHeroTag',
      child: MaterialButton(
        child: Icon(Icons.print),
        minWidth: MediaQuery.of(context).size.width / 2,
        onPressed: () async {
          if (fromScreen == 'history') {
            // ignore: unawaited_futures
            order.printReceipt(context);
          } else {
            final customerPaid = await _popUpPayment(context, order.totalPriceAfterDiscount);
            if (customerPaid != null) {
              final s = await order.checkout(supplier: context.read<Supplier>());
              // ignore: unawaited_futures
              order.printReceipt(context, customerPaid, s);
            }
          }
          Navigator.pop(context); // Go back to Lobby Screen
        },
      ),
    );
  }
}

class _ApplyDiscountButton extends StatelessWidget {
  final TableModel order;
  final String fromScreen;

  _ApplyDiscountButton(this.order, {required this.fromScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      child: Icon(Icons.local_offer),
      minWidth: MediaQuery.of(context).size.width / 2,
      onPressed: () async {
        final discountPct = await _popUpDiscount(context, order.totalPricePreDiscount);
        if (discountPct != null) {
          final supplier = context.read<Supplier>();
          order.applyDiscount((100 - discountPct) / 100, supplier);
        }
      },
    );
  }
}

Future<double?> _popUpDiscount(BuildContext context, double totalPrice) {
  final notif = ValueNotifier('1'); // notify which type of TextField to display
  final percentageController = TextEditingController(text: '20');
  final fixedPriceController = TextEditingController(text: Money.format(10000));

  final pctCtrl = TextField(
    controller: percentageController,
    keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
    inputFormatters: [NumberEL100Formatter()],
    textAlign: TextAlign.center,
    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.details_discount),
  );
  final fixCtrl = TextField(
    controller: fixedPriceController,
    keyboardType: TextInputType.numberWithOptions(signed: true, decimal: false),
    inputFormatters: [MoneyFormatter()],
    textAlign: TextAlign.center,
    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.details_discount),
  );

  return showDialog<double?>(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(12.0),
        content: ValueListenableBuilder(
          valueListenable: notif,
          builder: (context, v, __) {
            final drpDown = DropdownButton(
              value: notif.value,
              elevation: 8,
              isDense: true,
              underline: const SizedBox(), // no underline
              items: [
                DropdownMenuItem(child: Center(child: Text('%')), value: '1'),
                DropdownMenuItem(child: Center(child: Text(Money.symbol)), value: '2'),
              ],
              onChanged: (String? v) {
                if (v != null) notif.value = v;
              },
            );
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: v == '1' ? pctCtrl : fixCtrl,
                ),
                drpDown,
              ],
            );
          },
        ),
        actions: [
          TextButton(
            child: Icon(Icons.check),
            onPressed: () {
              final selected = notif.value == '1' ? percentageController : fixedPriceController;
              if (selected.text.isNotEmpty) {
                var discountPct = 0.0;
                if (notif.value == '2') {
                  // convert fixed price to percentage
                  discountPct = Money.unformat(selected.text) * 100 / totalPrice;
                } else {
                  discountPct = double.parse(selected.text);
                }
                Navigator.pop<double>(context, discountPct);
              }
            },
          ),
          TextButton(
            child: Icon(Icons.cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

Future<double?> _popUpPayment(BuildContext scaffoldCtx, double needsToPay) {
  final t = TextEditingController(text: Money.format(needsToPay));
  return showDialog<double?>(
    context: scaffoldCtx,
    barrierDismissible: false,
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
            child: Icon(Icons.check),
            onPressed: () {
              final p = Money.unformat(t.text);
              if (p < needsToPay) {
                final snackBar =
                    SnackBar(content: Text(AppLocalizations.of(context)!.details_notEnough));
                ScaffoldMessenger.of(scaffoldCtx).showSnackBar(snackBar);
              } else {
                Navigator.pop<double>(context, p.toDouble());
              }
            },
          ),
          TextButton(
            child: Icon(Icons.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
