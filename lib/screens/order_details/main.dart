import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../node_appbar_title.dart';
import './bottom_navbar.dart';
import './item_list.dart';
import '../../provider/src.dart';

class DetailsScreen extends StatelessWidget {
  final String? fromHeroTag;
  final String fromScreen;

  const DetailsScreen({this.fromHeroTag, required this.fromScreen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const NodeAppBarTitle(),
      ),
      bottomNavigationBar: BottomNavBar(fromScreen: fromScreen, fromHeroTag: fromHeroTag),
      floatingActionButton: fromScreen == 'history'
          ? FloatingActionButton(
              onPressed: () {
                context.read<OrderSupplier>().printClear(context: context);
                Navigator.pop(context);
              },
              elevation: 4.0,
              child: const Icon(Icons.print_sharp),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: const ItemList(),
    );
  }
}
