import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../common/common.dart';
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
    var summaryPrice = data?.fold(0, (previousValue, e) => previousValue + e.price);

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
              TextSpan(text: '(${Common.extractYYYYMMDD2(from)} - ${Common.extractYYYYMMDD2(to)})')
            ],
          ),
        ),
        actions: [], //TODO: add button to adjust date range
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
                title: Text(Common.extractYYYYMMDD3(data[index].checkoutTime)),
                onTap: () {}, //TODO: reuse Detais Screen -> allow soft delete a past order
                trailing: Text(
                  Money.format(data[index].price),
                  style: TextStyle(
                    letterSpacing: 3,
                    color: Colors.lightGreen,
                    fontSize: 20,
                  ),
                ),
              ),
            );
          }),
    );
  }
}
