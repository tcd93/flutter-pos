import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/common.dart';
import '../../../provider/src.dart';
import '../../popup_del.dart';

class OrderCard extends StatelessWidget {
  final int index;

  const OrderCard(this.index);

  @override
  Widget build(BuildContext context) {
    var order = context.select<HistoryOrderSupplier, Order>(
      (HistoryOrderSupplier supplier) => supplier.orders.elementAt(index),
    );

    var discountFlag = context.select<HistoryOrderSupplier, bool>(
      (HistoryOrderSupplier supplier) => supplier.discountFlag,
    );
    var del = order.isDeleted;
    return Stack(
      alignment: Alignment.center,
      children: [
        FractionallySizedBox(
          widthFactor: 0.95,
          child: Card(
            key: ObjectKey(order),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: del == true ? Colors.grey[400]!.withOpacity(0.5) : null,
                child: Text(order.id.toString()),
              ),
              title: Text(
                Common.extractYYYYMMDD3(order.checkoutTime),
                style: del == true ? TextStyle(color: Colors.grey[200]!.withOpacity(0.5)) : null,
              ),
              onLongPress: del == true
                  ? null
                  : () async {
                      var result = await popUpDelete(
                        context,
                        title:
                            Text(AppLocalizations.of(context)?.history_delPopUpTitle ?? 'Ignore?'),
                      );
                      if (result == true) {
                        context.read<HistoryOrderSupplier>().ignoreOrder(order);
                      }
                    },
              onTap: () {
                Navigator.pushNamed(context, '/order-details', arguments: {
                  'state': TableModel.withOrder(order),
                  'from': 'history',
                });
              },
              trailing: Text(
                Money.format(order.saleAmount(discountFlag)),
                style: TextStyle(
                  letterSpacing: 3,
                  color: del == true ? Colors.grey[200]!.withOpacity(0.5) : Colors.lightGreen,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
        if (del == true) const Divider(color: Colors.black, thickness: 1.0),
      ],
    );
  }
}
