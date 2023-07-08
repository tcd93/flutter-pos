import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/common.dart';
import '../../provider/src.dart';

class ItemList extends StatelessWidget {
  const ItemList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(),
        _Items(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final supplier = Provider.of<OrderSupplier>(context);
    final headline6Style = Theme.of(context).textTheme.titleLarge!;
    final priceAfterDisc = supplier.totalPriceAfterDiscount;
    return SafeArea(
      child: ListTile(
        dense: true,
        title: Text(
          Money.format(priceAfterDisc, symbol: true),
          style: (supplier.discountPercent > 0)
              ? headline6Style.apply(
                  color: Colors.green[400], fontWeightDelta: 7) //apply bold
              : headline6Style,
          textAlign: TextAlign.center,
        ),
        subtitle: supplier.discountPercent > 0
            ? Text(
                AppLocalizations.of(context)!.details_discountTxt(
                  Money.format(supplier.totalPricePreDiscount),
                  supplier.discountPercent.toStringAsFixed(2),
                ),
                textAlign: TextAlign.center,
              )
            : null,
      ),
    );
  }
}

class _Items extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final supplier = Provider.of<OrderSupplier>(context);
    return Expanded(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: supplier.activeLineItems.length,
        itemBuilder: (context, index) {
          final order = supplier.activeLineItems.elementAt(index);
          return Card(
            key: ObjectKey(order),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(order.quantity.toString()),
              ),
              title: Text(order.dishName),
              trailing: Text(Money.format(order.price * order.quantity)),
            ),
          );
        },
      ),
    );
  }
}
