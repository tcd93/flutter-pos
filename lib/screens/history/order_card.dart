import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/common.dart';
import '../../provider/src.dart';
import '../../storage_engines/connection_interface.dart';
import '../popup_del.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final DatabaseConnectionInterface storage;
  final Function(Order deletedOrder) onDeleted;

  const OrderCard(this.order, this.storage, {required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    var del = order.isDeleted;
    return StatefulBuilder(
      builder: (context, setInternalState) {
        return Stack(
          alignment: Alignment.center,
          children: [
            FractionallySizedBox(
              widthFactor: 0.95,
              child: Card(
                key: ObjectKey(order),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(order.orderID.toString()),
                    backgroundColor: del == true ? Colors.grey[400]!.withOpacity(0.5) : null,
                  ),
                  title: Text(
                    Common.extractYYYYMMDD3(order.checkoutTime),
                    style:
                        del == true ? TextStyle(color: Colors.grey[200]!.withOpacity(0.5)) : null,
                  ),
                  onLongPress: del == true
                      ? null
                      : () async {
                          var result = await popUpDelete(
                            context,
                            title: Text(AppLocalizations.of(context)!.history_delPopUpTitle),
                          );
                          if (result == true) {
                            var ord = await storage.delete(order.checkoutTime, order.orderID);
                            setInternalState(() => del = ord.isDeleted);
                            onDeleted.call(ord);
                          }
                        },
                  onTap: () {
                    Navigator.pushNamed(context, '/order-details', arguments: {
                      'state': TableModel(
                        order.tableID,
                        TableState.mock(
                          order.tableID,
                          order.lineItems,
                          orderID: order.orderID,
                          checkoutTime: order.checkoutTime,
                          discountRate: order.discountRate,
                        ),
                      ),
                      'from': 'history',
                    });
                  },
                  trailing: Text(
                    Money.format(order.totalPrice * order.discountRate),
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
      },
    );
  }
}
