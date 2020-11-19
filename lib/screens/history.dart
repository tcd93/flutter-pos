import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../common/common.dart';
import '../common/money_format/money.dart';
import '../models/immutable/order.dart';
import '../models/state/state_object.dart';
import '../models/table.dart';
import '../storage_engines/connection_interface.dart';

@immutable
class HistoryScreen extends StatelessWidget {
  final DatabaseConnectionInterface database;

  /// The "base" listenable, updating this value will rebuild ListView & update the `totalPrice`
  final ValueNotifier<DateTimeRange> listenableRange;

  /// The `totalPrice` that displays on AppBar
  final ValueNotifier<int> listenablePrice;

  // `database` must be passed in or otherwise cause deadlocks during unit test!
  HistoryScreen(this.database, [DateTime from, DateTime to])
      : listenableRange = ValueNotifier(
          DateTimeRange(
            start: from ?? DateTime.now(),
            end: to ?? DateTime.now(),
          ),
        ),
        listenablePrice = ValueNotifier(0);

  static int _calculateTotalPrice(List<Order> orders) => orders.fold(
        0,
        (previousValue, e) => previousValue + (e.isDeleted == true ? 0 : e.price),
      );

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding HistoryScreen...');

    return Scaffold(
      appBar: AppBar(
        title: _LeadingTitle(
          displayRange: listenableRange,
          summaryPrice: listenablePrice,
        ),
        bottomOpacity: 0.5,
        actions: [
          FlatButton(
            child: Icon(Icons.date_range),
            onPressed: () async {
              final selectedRange = await showDateRangePicker(
                context: context,
                initialDateRange: DateTimeRange(
                  start: listenableRange.value.start,
                  end: listenableRange.value.end,
                ),
                firstDate: DateTime.now().add(const Duration(days: -30)),
                lastDate: DateTime.now(),
                helpText: 'Select range',
              );

              // notify all listeners for rebuild when user selects different range
              if (selectedRange != null &&
                  (selectedRange.start.difference(listenableRange.value.start).inDays != 0 ||
                      selectedRange.end.difference(listenableRange.value.end).inDays != 0)) {
                listenableRange.value = selectedRange;
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<DateTimeRange>(
        valueListenable: listenableRange, // rebuild list when selected range changes
        builder: (_, range, __) {
          final data = database.getRange(range.start, range.end);
          // update price (notify rebuild on AppBar) when list building is done
          WidgetsBinding.instance.addPostFrameCallback((_) {
            listenablePrice.value = _calculateTotalPrice(data);
          });

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: data?.length ?? 0,
            itemBuilder: (context, index) => _OrderSnapshot(
              data[index],
              database,
              onDeleted: (deletedOrder) {
                // rebuild appbar (to update price) when an order is marked deleted
                listenablePrice.value -= deletedOrder.price;
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderSnapshot extends StatelessWidget {
  final Order order;
  final DatabaseConnectionInterface storage;
  final Function(Order deletedOrder) onDeleted;

  _OrderSnapshot(this.order, this.storage, {this.onDeleted});

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding _OrderSnapshot...');

    // in Dart, default is boolean is "null" !?
    var isDeleted = order.isDeleted ?? false;

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
                    backgroundColor: isDeleted == true ? Colors.grey[400].withOpacity(0.5) : null,
                  ),
                  title: Text(
                    Common.extractYYYYMMDD3(order.checkoutTime),
                    style: isDeleted == true
                        ? TextStyle(
                            color: Colors.grey[200].withOpacity(0.5),
                          )
                        : null,
                  ),
                  onLongPress: isDeleted == true // allow delete once
                      ? null
                      : () async {
                          var result = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Soft delete?'),
                              actions: [
                                FlatButton(
                                  child: Text('Cancel'),
                                  onPressed: () => Navigator.of(context).pop(false),
                                ),
                                FlatButton(
                                  child: Text('Yes'),
                                  onPressed: () => Navigator.of(context).pop(true),
                                ),
                              ],
                            ),
                          );

                          if (result == true) {
                            var deletedOrd = await storage.delete(
                              order.checkoutTime,
                              order.orderID,
                            );
                            setInternalState(() => isDeleted = deletedOrd.isDeleted);

                            onDeleted?.call(deletedOrd);
                          }
                        },
                  onTap: () {
                    Navigator.pushNamed(context, '/order-details', arguments: {
                      'model': TableModel(
                        null, //empty supplier, no persistency needs to be done here
                        -1,
                        StateObject.createFrom(order),
                      ),
                      'from': 'history',
                    });
                  },
                  trailing: Text(
                    Money.format(order.price),
                    style: TextStyle(
                      letterSpacing: 3,
                      color:
                          isDeleted == true ? Colors.grey[200].withOpacity(0.5) : Colors.lightGreen,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            if (isDeleted == true) // A "strike-thru" effect for Card widget
              Divider(
                color: Colors.black,
                thickness: 1.0,
              ),
          ],
        );
      },
    );
  }
}

class _LeadingTitle extends StatelessWidget {
  final ValueListenable<DateTimeRange> displayRange;
  final ValueListenable<int> summaryPrice;

  _LeadingTitle({this.displayRange, this.summaryPrice});

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding _LeadingTitle...');

    return Wrap(
      direction: Axis.vertical,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: summaryPrice,
          builder: (_, price, __) {
            return Text(
              '${Money.format(price ?? 0)}',
              style: TextStyle(
                color: Colors.lightGreen,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            );
          },
        ),
        ValueListenableBuilder<DateTimeRange>(
          valueListenable: displayRange,
          builder: (_, range, __) => Text(
            '(${Common.extractYYYYMMDD2(range.start)} - ${Common.extractYYYYMMDD2(range.end)})',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ],
    );
  }
}
