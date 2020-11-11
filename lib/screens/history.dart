import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../common/money_format/money.dart';

import '../database_factory.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding HistoryScreen...');

    final storage = DatabaseFactory('local-storage').storage;
    final data = storage.get('20201111');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Total Price',
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: [],
      ),
      body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Card(
              key: ObjectKey(data[index]),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(data[index]['orderID'].toString()),
                ),
                title: Text('20201111'),
                trailing: Text(
                  Money.format(data[index]['price']).toString(),
                ),
              ),
            );
          }),
    );
  }
}
