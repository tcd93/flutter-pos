import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../common/common.dart';
import '../common/money_format/money.dart';

import '../storage_engines/connection_interface.dart';

class _HistoryState {
  DateTime from;
  DateTime to;
  int summaryPrice;

  _HistoryState(DateTime start, DateTime end, this.summaryPrice) {
    from = start ?? DateTime.now();
    to = end ?? DateTime.now();

    assert(to.isAtSameMomentAs(from) || to.isAfter(from));
  }
}

class HistoryScreen extends StatelessWidget {
  final DatabaseConnectionInterface database;
  final DateTime from;
  final DateTime to;
  final _HistoryState _state;

  HistoryScreen(this.database, [this.from, this.to]) : _state = _HistoryState(from, to, 0);

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding HistoryScreen...');

    // `database` must be passed in or otherwise cause deadlocks during unit test!
    final storage = database;
    final data = storage.getRange(from ?? DateTime.now(), to ?? DateTime.now());
    _state.summaryPrice = data?.fold(
          0,
          (previousValue, e) => previousValue + (e.isDeleted == true ? 0 : e.price),
        ) ??
        0;

    final notifier = ValueNotifier(_state);

    return Scaffold(
      appBar: AppBar(
        // not using `setState` because it will redraw entire screen
        // we only want to redraw the AppBar
        title: ValueListenableBuilder<_HistoryState>(
          valueListenable: notifier,
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
                  start: from,
                  end: to,
                ),
                firstDate: from.add(const Duration(days: -180)),
                lastDate: DateTime.now(),
                helpText: '',
              );
              if (range != null) {
                // get new range
                // TODO - BUG: redraw screen here
                notifier.value = _HistoryState(
                  range.start,
                  range.end,
                  _state.summaryPrice,
                );
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: data?.length ?? 0,
        itemBuilder: (context, index) => _OrderSnapshot(
          data[index],
          storage,
          onDeleted: (deletedOrder) {
            notifier.value = _HistoryState(
              from,
              to,
              _state.summaryPrice - deletedOrder.price, // update price
            );
          },
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

    var isDeleted = order.isDeleted;

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
                  onLongPress: () async {
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
                  onTap: () {}, //TODO: reuse Detais Screen -> allow soft delete a past order
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
