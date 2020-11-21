import 'dart:async';

import 'package:flutter/material.dart';
import '../common/money_format/money.dart';

import '../models/dish.dart';

/// Throttle the input action
class Debouncer {
  final int milliseconds;
  Timer _timer;

  Debouncer({this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class EditMenuScreen extends StatefulWidget {
  EditMenuScreen() : super();

  final String title = "Menu Editor";

  @override
  EditMenuScreenState createState() => EditMenuScreenState();
}

class EditMenuScreenState extends State<EditMenuScreen> {
  final _debouncer = Debouncer(milliseconds: 300);
  List<Dish> dishes;
  List<Dish> filteredDishes;

  @override
  void initState() {
    super.initState();
    setState(() {
      dishes = Dish.getMenu();
      filteredDishes = dishes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(15.0),
              hintText: 'Filter by dish name',
            ),
            onChanged: (string) {
              _debouncer.run(() {
                setState(() {
                  filteredDishes = dishes
                      .where((u) => (u.dish.toLowerCase().contains(string.toLowerCase())))
                      .toList();
                });
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: filteredDishes.length,
              itemBuilder: (_, index) {
                return Card(
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(filteredDishes[index].dish),
                          Chip(
                            label: Text(Money.format(filteredDishes[index].price)),
                            backgroundColor: Colors.lightGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
