import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../common/money_format/money.dart';

import '../database_factory.dart';

class HistoryScreen extends StatefulWidget {
  final DateTime from;
  final DateTime to;

  HistoryScreen([this.from, this.to]);

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

    final storage = DatabaseFactory('local-storage').storage;
    final data = storage.getRange(from, to);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Total Price', //TODO: calculate prifit here
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: [],
      ),
      body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: data?.length ?? 0,
          itemBuilder: (context, index) {
            return Card(
              key: ObjectKey(data[index]),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(data[index].orderID.toString()),
                ),
                title: Text(data[index].checkoutTime.toString()), //TODO: format date display
                trailing: Text(
                  Money.format(data[index].price),
                ),
              ),
            );
          }),
    );
  }
}
