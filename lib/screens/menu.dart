import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../common/counter/counter.dart';

import '../models/dish.dart';
import '../models/table.dart';
import '../models/tracker.dart';

class MenuScreen extends StatelessWidget {
  final int tableID;
  final String fromHeroTag;

  MenuScreen(this.tableID, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    final model = context.select<OrderTracker, TableModel>(
        (tracker) => tracker.getTable(tableID));

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu', style: Theme.of(context).textTheme.headline1),
        actions: [
          Hero(
            tag: fromHeroTag,
            child: FlatButton(
              child: Icon(FontAwesomeIcons.check),
              onPressed: null,
            ),
          ),
        ],
      ),
      body: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          itemCount: Dish.getMenu().length,
          itemBuilder: (context, index) {
            return Counter(
              model.getOrder(index)?.quantity ?? 0,
              onIncrement: (_) {
                model.getOrPutOrder(index).quantity++;
                debugPrint(
                    'current order: ${model.getOrder(index).toString()}');
              },
              onDecrement: (_) {
                model.getOrPutOrder(index).quantity--;
                debugPrint(
                    'current order: ${model.getOrder(index).toString()}');
              },
              imagePath: Dish.getMenu()[index].imagePath,
              subtitle: Dish.getMenu()[index].dish,
            );
          }),
    );
  }
}
