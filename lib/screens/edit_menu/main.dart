import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  /// The entire menu (all m)
  late final Menu m;

  /// The filtered list of m if user use the filter input,
  /// should be the central state object
  late List<Dish> filteredDishes;

  // New code
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    m = context.read<MenuSupplier>().menu;
    filteredDishes = m.toList(growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      onAddDish: (Dish newDish) {
        final supplier = context.read<MenuSupplier>();
        supplier.addDish(newDish);
        setState(() {
          filteredDishes.add(newDish);
        });
      },
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(15.0),
                hintText: AppLocalizations.of(context)?.edit_menu_filterHint,
              ),
              onChanged: (string) {
                _debouncer.run(() {
                  setState(() {
                    filteredDishes = m
                        .where((u) => (u.dish.toLowerCase().contains(string.toLowerCase())))
                        .toList();
                  });
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(10.0),
                controller: _scrollController,
                itemCount: filteredDishes.length,
                itemBuilder: (_, index) {
                  return _ListItem(
                    filteredDishes[index],
                    onEdit: (editedDish) {
                      final supplier = context.read<MenuSupplier>();
                      supplier.updateDish(editedDish);
                      setState(() {
                        filteredDishes[index] = editedDish;
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
                      final supplier = context.read<MenuSupplier>();
                      supplier.removeDish(filteredDishes[index]);
                      setState(() {
                        filteredDishes.removeAt(index);
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

  const _ListItem(this.dish, {required this.onEdit, required this.onDelete, required this.onShow});

  @override
  __ListItemState createState() => __ListItemState();
}

class __ListItemState extends State<_ListItem> {
  CrossFadeState currentState = CrossFadeState.showFirst;
  // attach this global key to the "expanded" widget to get the sizes
  // for the `ensureVisible` function to work!
  final GlobalKey<__ListItemState> _gk = GlobalKey();

  Uint8List? pickedImage;

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
          widget.onDelete.call();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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

    return Padding(
      key: _gk,
      padding: const EdgeInsets.all(8.0),
      child: FormContent(
        inputs: buildInputs(context, dishNameController, priceController, TextAlign.start),
        avatar: Avatar(
          imgProvider: pickedImage != null ? MemoryImage(pickedImage!) : dish.imgProvider,
          onNew: (image) {
            setState(() => pickedImage = image);
          },
        ),
        gap: 12.0,
        buttonMinWidth: 70.0,
        onSubmit: () {
          if (priceController.text.isNotEmpty && dishNameController.text.isNotEmpty) {
            final edittedDish = Dish(
              dish.id,
              dishNameController.text,
              Money.unformat(priceController.text).toDouble(),
              pickedImage,
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
