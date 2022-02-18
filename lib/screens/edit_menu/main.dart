import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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

  /// The filtered list of m if user use the filter input,
  /// should be the central state object
  List<Dish>? filteredDishes;

  // New code
  final ScrollController _scrollController = ScrollController();

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      onAddDish: (name, price, [image]) async {
        final supplier = context.read<MenuSupplier>();
        final dish = await supplier.addDish(name, price, image);
        setState(() {
          filteredDishes?.add(dish);
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
                    filteredDishes = context
                        .read<MenuSupplier>()
                        .menu
                        .where((u) => (u.dish.toLowerCase().contains(string.toLowerCase())))
                        .toList();
                  });
                });
              },
            ),
            _MenuList(
              builder: (initialList) {
                filteredDishes ??= initialList;

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(10.0),
                  controller: _scrollController,
                  itemCount: filteredDishes!.length,
                  itemBuilder: (_, index) {
                    return _ListItem(
                      filteredDishes![index],
                      onShow: (ctx) {
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
                        setState(() {
                          filteredDishes!.removeAt(index);
                        });
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  final Widget Function(List<Dish> initialList) builder;

  /// Return generic text 'No data found' or build a list of [_ListItem]
  const _MenuList({required this.builder});

  @override
  Widget build(BuildContext context) {
    final dishes = context.select<MenuSupplier?, List<Dish>?>((value) {
      return value?.menu.toList();
    });
    if (dishes == null) {
      return const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      );
    }
    if (dishes.isEmpty) {
      return Text(AppLocalizations.of(context)?.generic_empty ?? 'No data found');
    }
    return Expanded(child: builder(dishes));
  }
}

class _ListItem extends HookWidget {
  final Function(BuildContext ctx) onShow;
  final VoidCallback onDelete;
  final Dish dish;

  const _ListItem(this.dish, {required this.onDelete, required this.onShow});

  @override
  Widget build(BuildContext context) {
    final currentState = useState(CrossFadeState.showFirst);

    return Card(
      child: AnimatedCrossFade(
        duration: _animDuration,
        crossFadeState: currentState.value,
        firstChild: collapsed(context, dish, currentState),
        secondChild: expanded(context, dish, currentState),
      ),
    );
  }

  Widget collapsed(BuildContext context, Dish dish, ValueNotifier<CrossFadeState> currentState) {
    return InkWell(
      onTap: () {
        currentState.value = CrossFadeState.showSecond;
        onShow(context);
      },
      onLongPress: () async {
        var delete = await popUpDelete(context);
        if (delete != null && delete) {
          final supplier = context.read<MenuSupplier>();
          supplier.removeDish(dish);
          onDelete();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dish.dish),
            Chip(
              label: Text(Money.format(dish.price)),
              backgroundColor: RallyColors.primaryColor,
              labelStyle: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget expanded(BuildContext context, Dish dish, ValueNotifier<CrossFadeState> currentState) {
    final dishNameController = useTextEditingController(text: dish.dish);
    final priceController = useTextEditingController(text: Money.format(dish.price));
    final pickedImage = useState<Uint8List?>(null);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormContent(
        inputs: buildInputs(context, dishNameController, priceController, TextAlign.start),
        avatar: Avatar(
          imgProvider:
              pickedImage.value != null ? MemoryImage(pickedImage.value!) : dish.imgProvider,
          onNew: (image) {
            pickedImage.value = image;
          },
        ),
        gap: 12.0,
        buttonMinWidth: 70.0,
        onSubmit: () {
          if (priceController.text.isNotEmpty && dishNameController.text.isNotEmpty) {
            final supplier = context.read<MenuSupplier>();
            supplier.updateDish(
              dish,
              dishNameController.text,
              Money.unformat(priceController.text).toDouble(),
              pickedImage.value,
            );
            currentState.value = CrossFadeState.showFirst;
          }
        },
        onCancel: () {
          currentState.value = CrossFadeState.showFirst;
        },
      ),
    );
  }
}
