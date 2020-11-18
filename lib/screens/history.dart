import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../common/common.dart';
import '../common/money_format/money.dart';
import '../models/immutable/order.dart';
import '../models/state/state_object.dart';
import '../models/table.dart';
import '../storage_engines/connection_interface.dart';

class _HistoryState {
  DateTime from;
  DateTime to;
  int summaryPrice = 0;

  _HistoryState(DateTime start, DateTime end, this.summaryPrice) {
    from = start ?? DateTime.now();
    to = end ?? DateTime.now();

    assert(to.isAtSameMomentAs(from) || to.isAfter(from));
  }
}

@immutable
class HistoryScreen extends StatelessWidget {
  final DatabaseConnectionInterface database;

  /// Initial [_HistoryState] when the screen is built, should be used only for [ValueNotifier]
  final _HistoryState _initialState;

  /// Initial list of [Order] when the screen is built, should be used only for [ValueNotifier]
  final List<Order> _initialOrders;

  // `database` must be passed in or otherwise cause deadlocks during unit test!
  HistoryScreen(this.database, [DateTime from, DateTime to])
      : _initialState = _HistoryState(
            from,
            to,
            _calculateTotalPrice(
              database.getRange(
                from ?? DateTime.now(),
                to ?? DateTime.now(),
              ),
            )),
        _initialOrders = database.getRange(
          from ?? DateTime.now(),
          to ?? DateTime.now(),
        );

  static int _calculateTotalPrice(List<Order> orders) => orders.fold(
        0,
        (previousValue, e) => previousValue + (e.isDeleted == true ? 0 : e.price),
      );

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding HistoryScreen...');

    // not using `setState` because it will redraw entire screen
    // we only want to redraw specific sections
    final appbarNotifier = ValueNotifier(_initialState);
    final listViewNotifier = ValueNotifier(_initialOrders);

    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<_HistoryState>(
          valueListenable: appbarNotifier,
          builder: (_, newState, __) => _LeadingTitle(
            from: newState.from,
            to: newState.to,
            summaryPrice: newState.summaryPrice,
          ),
        ),
        actions: [
          FlatButton(
            child: Icon(Icons.date_range),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                initialDateRange: DateTimeRange(
                  start: appbarNotifier.value.from,
                  end: appbarNotifier.value.to,
                ),
                firstDate: _initialState.from.add(const Duration(days: -180)),
                lastDate: DateTime.now(),
                helpText: '',
              );

              // notify all listeners for rebuild when user selects different range
              if (range != null &&
                  (range.start.difference(appbarNotifier.value.from).inDays != 0 ||
                      range.end.difference(appbarNotifier.value.to).inDays != 0)) {
                listViewNotifier.value = database.getRange(range.start, range.end);

                appbarNotifier.value = _HistoryState(
                  range.start,
                  range.end,
                  _calculateTotalPrice(listViewNotifier.value),
                );
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Order>>(
        valueListenable: listViewNotifier,
        builder: (_, data, __) => ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: data?.length ?? 0,
          itemBuilder: (context, index) => _OrderSnapshot(
            data[index],
            database,
            onDeleted: (deletedOrder) {
              // rebuild appbar (to update price) when an order is marked deleted
              appbarNotifier.value = _HistoryState(
                appbarNotifier.value.from,
                appbarNotifier.value.to,
                appbarNotifier.value.summaryPrice - deletedOrder.price,
              );
            },
          ),
        ),
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
                    //TODO: disable print button on this context
                    Navigator.pushNamed(context, '/order-details', arguments: {
                      'model': TableModel(
                        null, //empty supplier, no persistency needs to be done here
                        -1,
                        StateObject.createFrom(order),
                      ),
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
  final DateTime from;
  final DateTime to;
  final int summaryPrice;

  _LeadingTitle({this.from, this.to, this.summaryPrice});

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding _LeadingTitle...');

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.headline6,
        children: [
          TextSpan(
            text: '${Money.format(summaryPrice ?? 0)}',
            style: TextStyle(
              color: Colors.lightGreen,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          TextSpan(text: ' '),
          TextSpan(
            text: '(${Common.extractYYYYMMDD2(from)} - ${Common.extractYYYYMMDD2(to)})',
          ),
        ],
      ),
    );
  }
}
