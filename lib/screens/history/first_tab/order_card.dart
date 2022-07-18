import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/common.dart';
import '../../../provider/src.dart';
import '../../order_details/main.dart';
import '../../popup_del.dart';

class OrderCard extends StatelessWidget {
  final int index;

  const OrderCard(this.index);

  @override
  Widget build(BuildContext context) {
    // the 'order' is nullable here as the length of 'orders' array might change
    var order = context.select<HistoryOrderSupplier, Order?>(
      (HistoryOrderSupplier supplier) =>
          (index < supplier.orders.length) ? supplier.orders.elementAt(index) : null,
    );
    if (order == null) return const SizedBox.shrink();

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
                      final histOrderSupplier = context.read<HistoryOrderSupplier>();
                      var result = await popUpDelete(
                        context,
                        title:
                            Text(AppLocalizations.of(context)?.history_delPopUpTitle ?? 'Ignore?'),
                      );
                      if (result == true) {
                        histOrderSupplier.ignoreOrder(order);
                      }
                    },
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return ChangeNotifierProvider.value(
                      value: OrderSupplier(order: order),
                      child: const DetailsScreen(fromScreen: 'history'),
                    );
                  },
                ));
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
