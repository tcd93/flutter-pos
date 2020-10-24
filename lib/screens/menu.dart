import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../common/counter/counter.dart';
import '../models/table.dart';
import '../models/tracker.dart';

class MenuScreen extends StatelessWidget {
  final int tableID;
  final String fromHeroTag;

  MenuScreen(this.tableID, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    final model = context.select<OrderTracker, TableModel>((tracker) => tracker.getTable(tableID));
    var orderIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu', style: Theme.of(context).textTheme.headline1),
      ),
      // TODO: create a list view of counters, index 0 is dummy
      body: Counter(
        model.getOrder()[orderIndex].quantity,
        onIncrement: (_) {
          model.getOrder()[orderIndex].quantity++;
          return;
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: fromHeroTag,
        child: Icon(FontAwesomeIcons.plusSquare),
        onPressed: null,
      ),
    );
  }
}
