import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../common/common.dart';
import '../common/money_format/money.dart';

import '../storage_engines/connection_interface.dart';

class HistoryScreen extends StatefulWidget {
  final DatabaseConnectionInterface database;
  final DateTime from;
  final DateTime to;

  HistoryScreen(this.database, [this.from, this.to]);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime from;
  DateTime _to;

  DateTime get to => _to;

  set to(DateTime to) {
    assert(to.isAtSameMomentAs(from) || to.isAfter(from));
    _to = to;
  }

  @override
  void initState() {
    super.initState();
    from = widget.from ?? DateTime.now();
    to = widget.to ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding HistoryScreen...');

    // `database` must be passed in or otherwise cause deadlocks during unit test!
    final storage = widget.database;
    final data = storage.getRange(from, to);
    var summaryPrice = data?.fold(
      0,
      (previousValue, e) => previousValue + e.price,
    );
    return Scaffold(
      appBar: AppBar(
        title: RichText(
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
                setState(() {
                  from = range.start;
                  to = range.end;
                });
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
        ),
      ),
    );
  }
}

class _OrderSnapshot extends StatelessWidget {
  final Order order;
  final DatabaseConnectionInterface storage;

  _OrderSnapshot(this.order, this.storage);

  @override
  Widget build(BuildContext context) {
    var isDeleted = order.isDeleted;

    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          overflow: Overflow.visible,
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
                      builder: (context) {
                        final cancelButton = FlatButton(
                          child: Text('No'),
                          onPressed: () => Navigator.of(context).pop(false),
                        );
                        final continueButton = FlatButton(
                          child: Text('Yes'),
                          onPressed: () => Navigator.of(context).pop(true),
                        );

                        return AlertDialog(
                          title: Text('Soft delete?'),
                          actions: [
                            cancelButton,
                            continueButton,
                          ],
                        );
                      },
                    );

                    if (result == true) {
                      var deletedOrd = await storage.delete(
                        order.checkoutTime,
                        order.orderID,
                      );
                      setState(() => isDeleted = deletedOrd.isDeleted);
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
