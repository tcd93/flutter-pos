import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    final provider = Provider.of<HistorySupplierByDate>(context);
    final order = provider.data.elementAt(index);
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
                        await provider.ignoreOrder(order, index);
                      }
                    },
              onTap: () {
                Navigator.pushNamed(context, '/order-details', arguments: {
                  'state': TableModel.withOrder(
                    Order.create(
                      tableID: order.tableID,
                      lineItems: order.lineItems,
                      orderID: order.id,
                      checkoutTime: order.checkoutTime,
                      discountRate: order.discountRate,
                    ),
                  ),
                  'from': 'history',
                });
              },
              trailing: Text(
                Money.format(provider.saleAmountOf(order)),
                style: TextStyle(
                  letterSpacing: 3,
                  color: del == true ? Colors.grey[200]!.withOpacity(0.5) : Colors.lightGreen,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
        if (del == true) Divider(color: Colors.black, thickness: 1.0),
      ],
    );
  }
}
