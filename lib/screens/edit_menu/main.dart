import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './menu_form.dart';
import '../../common/common.dart';
import '../../theme/rally.dart';
import '../../provider/src.dart';
import '../popup_del.dart';
import '../avatar.dart';
import 'custom_scaffold.dart';
import 'debouncer.dart';

const _animDuration = Duration(milliseconds: 500);

class EditMenuScreen extends StatefulWidget {
  @override
  EditMenuScreenState createState() => EditMenuScreenState();
}

class EditMenuScreenState extends State<EditMenuScreen> {
  final _debouncer = Debouncer(milliseconds: 300);

  /// The entire menu (all dishes)
  final dishes = Dish.getMenu().toList();

  /// The filtered list of dishes if user use the filter input,
  /// should be the central state object
  late List<Dish> filteredDishes;

  // New code
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    setState(() {
      filteredDishes = dishes.toList(growable: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      onAddDish: (Dish newDish) {
        Dish.addMenu(newDish);
        setState(() {
          filteredDishes.add(newDish);
          dishes.add(newDish);
        });
      },
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(15.0),
                hintText: AppLocalizations.of(context)!.edit_menu_filterHint,
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
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(10.0),
                controller: _scrollController,
                itemCount: filteredDishes.length,
                itemBuilder: (_, index) {
                  return _ListItem(
                    filteredDishes[index],
                    onEdit: (editedDish) async {
                      Dish.setMenu(editedDish);
                      setState(() {
                        filteredDishes[index] = editedDish;
                        dishes[index] = editedDish;
                      });
                    },
                    onShow: (keyOfExpandedWidget) {
                      final ctx = keyOfExpandedWidget.currentContext!;
                      // ensure visibility of this widget after expanded (so it is not obscured by the appbar),
                      // but only call after animation from the `AnimatedCrossFade` is completed so the `ctx.findRenderObject`
                      // find the render object at full height to work with
                      Timer(_animDuration, () {
                        _scrollController.position.ensureVisible(
                          ctx.findRenderObject()!,
                          duration: _animDuration,
                          curve: Curves.easeOut,
                          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
                        );
                      });
                    },
                    onDelete: () {
                      Dish.deleteMenu(filteredDishes[index]);
                      setState(() {
                        filteredDishes.removeAt(index);
                        dishes.removeAt(index);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListItem extends StatefulWidget {
  final Function(Dish) onEdit;
  final Function(GlobalKey keyOfExpandedWidget) onShow;
  final VoidCallback onDelete;
  final Dish dish;

  _ListItem(this.dish, {required this.onEdit, required this.onDelete, required this.onShow});

  @override
  __ListItemState createState() => __ListItemState();
}

class __ListItemState extends State<_ListItem> {
  CrossFadeState currentState = CrossFadeState.showFirst;
  // attach this global key to the "expanded" widget to get the sizes
  // for the `ensureVisible` function to work!
  final GlobalKey<__ListItemState> _gk = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: AnimatedCrossFade(
        duration: _animDuration,
        crossFadeState: currentState,
        firstChild: collapsed(context),
        secondChild: expanded(context, widget.dish, widget.onEdit),
      ),
    );
  }

  Widget collapsed(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          currentState = CrossFadeState.showSecond;
        });
        widget.onShow.call(_gk);
      },
      onLongPress: () async {
        var delete = await popUpDelete(context);
        if (delete != null && delete) {
          Dish.deleteMenu(widget.dish);
          widget.onDelete.call();
        }
      },
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.dish.dish),
            Chip(
              label: Text(Money.format(widget.dish.price)),
              backgroundColor: RallyColors.primaryColor,
              labelStyle: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget expanded(BuildContext context, Dish dish, Function(Dish) onEdit) {
    final dishNameController = TextEditingController(text: dish.dish);
    final priceController = TextEditingController(text: Money.format(dish.price));
    var img = dish.imageBytes;

    return Padding(
      key: _gk,
      padding: EdgeInsets.all(8.0),
      child: FormContent(
        inputs: buildInputs(context, dishNameController, priceController, TextAlign.start),
        avatar: Avatar(
          imageData: dish.imageBytes,
          onNew: (image) => img = image,
        ),
        gap: 12.0,
        buttonMinWidth: 70.0,
        onSubmit: () {
          if (priceController.text.isNotEmpty && dishNameController.text.isNotEmpty) {
            final edittedDish = Dish(
              dish.id,
              dishNameController.text,
              Money.unformat(priceController.text).toDouble(),
              img,
            );
            setState(() {
              currentState = CrossFadeState.showFirst;
            });
            onEdit(edittedDish);
          }
        },
        onCancel: () {
          setState(() {
            currentState = CrossFadeState.showFirst;
          });
        },
      ),
    );
  }
}
