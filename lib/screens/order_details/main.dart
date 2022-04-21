import 'package:flutter/material.dart';
import 'package:posapp/provider/supplier/order_supplier.dart';
import 'package:provider/provider.dart';

import './bottom_navbar.dart';
import './item_list.dart';
import '../../theme/rally.dart';
import '../../provider/src.dart';

class DetailsScreen extends StatelessWidget {
  final String? fromHeroTag;
  final String fromScreen;

  const DetailsScreen({this.fromHeroTag, required this.fromScreen});

  @override
  Widget build(BuildContext context) {
    final supplier = Provider.of<OrderSupplier>(context, listen: false);
    return Scaffold(
      bottomNavigationBar: BottomNavBar(fromScreen: fromScreen, fromHeroTag: fromHeroTag),
      floatingActionButton: fromScreen == 'history'
          ? FloatingActionButton(
              onPressed: () {
                supplier.printClear(context: context);
                Navigator.pop(context);
              },
              elevation: 4.0,
              backgroundColor: RallyColors.buttonColor,
              child: const Icon(Icons.print_sharp),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: const ItemList(),
    );
  }
}
