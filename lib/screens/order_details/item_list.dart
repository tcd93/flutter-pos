import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/common.dart';
import '../../provider/src.dart';

class ItemList extends StatelessWidget {
  final String? fromScreen;
  final TableModel order;

  const ItemList(this.order, {this.fromScreen});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(order),
        _Items(order.lineItems, fromScreen),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final TableModel order;

  const _Header(this.order);

  @override
  Widget build(BuildContext context) {
    context.watch<Supplier>();
    final headline6Style = Theme.of(context).textTheme.headline6!;
    final priceAfterDisc = order.totalPriceAfterDiscount;
    return SafeArea(
      child: ListTile(
        dense: true,
        title: Text(
          '${Money.format(priceAfterDisc, symbol: true)}',
          style: (order.discountPercent > 0)
              ? headline6Style.apply(color: Colors.green[400], fontWeightDelta: 7) //apply bold
              : headline6Style,
          textAlign: TextAlign.center,
        ),
        subtitle: order.discountPercent > 0
            ? Text(
                AppLocalizations.of(context)!.details_discountTxt(
                  Money.format(order.totalPricePreDiscount),
                  order.discountPercent.toStringAsFixed(2),
                ),
                textAlign: TextAlign.center,
              )
            : null,
      ),
    );
  }
}

class _Items extends StatelessWidget {
  final List<LineItem> orders;
  final String? fromScreen;

  const _Items(this.orders, this.fromScreen);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return Card(
            key: ObjectKey(orders[index]),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(orders[index].quantity.toString()),
              ),
              title: Text(
                fromScreen == 'history'
                    ? orders[index].dishName
                    : Dish.ofID(orders[index].dishID)?.dish ??
                        orders[index].dishName + AppLocalizations.of(context)!.details_liDeleted,
              ),
              trailing: Text(
                Money.format(fromScreen == 'history'
                    ? orders[index].price * orders[index].quantity
                    : Dish.ofID(orders[index].dishID)?.price ??
                        orders[index].price * orders[index].quantity),
              ),
            ),
          );
        },
      ),
    );
  }
}
