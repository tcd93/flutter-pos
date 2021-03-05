import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../common/common.dart';
import '../../theme/rally.dart';
import '../../provider/src.dart';
import '../avatar.dart';
import 'menu_form.dart';

const Duration _animDuration = Duration(milliseconds: 600);

/// Custom [Scaffold] with [AnimatedContainer] as bottomNavigationBar &
/// a centered FAB which can add new dish to menu list.
///
/// When FAB's clicked, the entire bottom appbar will animate up (like a bottom sheet)
/// showing a menu-add form.
class CustomScaffold extends StatefulWidget {
  final Widget body;

  /// called when user press the central FAB in bottom appbar
  final void Function(Dish newDish) onAddDish;

  CustomScaffold({required this.body, required this.onAddDish});

  @override
  _CustomScaffoldState createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> with SingleTickerProviderStateMixin {
  final expanded = ValueNotifier(false);
  final dishNameController = TextEditingController();
  final priceController = TextEditingController();
  late AnimationController animController;

  @override
  void initState() {
    animController = AnimationController(vsync: this, duration: _animDuration);

    // link animation with the "state" of value listenable
    expanded.addListener(() {
      if (expanded.value == true) {
        animController.forward();
      } else {
        animController.reverse();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    animController.dispose();
    expanded.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomScaffold oldWidget) {
    dishNameController.clear();
    priceController.clear();
    super.didUpdateWidget(oldWidget);
  }

  Future<bool> _preventNavPop() async {
    expanded.value = false;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? displayImg;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 6.0,
        child: _BottomAppBarContainer(
          expanded,
          child: Padding(
            padding: EdgeInsets.only(top: 70.0, left: 70.0, right: 70.0),
            child: WillPopScope(
              onWillPop: _preventNavPop,
              child: FormContent(
                inputs: buildInputs(context, dishNameController, priceController),
                onSubmit: () {
                  if (priceController.text.isNotEmpty && dishNameController.text.isNotEmpty) {
                    final newDish = Dish(
                      Dish.newID(),
                      dishNameController.text,
                      Money.unformat(priceController.text).toDouble(),
                      displayImg,
                    );
                    widget.onAddDish(newDish);
                    expanded.value = false;
                  }
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _CenterDockedButton(
        expanded,
        onNewAvatar: (img) => displayImg = img,
        animation: animController,
      ),
      body: ValueListenableBuilder(
        valueListenable: expanded,
        builder: (BuildContext context, bool value, Widget? body) {
          return GestureDetector(
            // hides the bottom bar on outside tap
            onTap: () {
              if (expanded.value) expanded.value = false;
            },
            child: _ColoredBarrierLayer(
              expanded,
              child: body!,
              animation: animController,
            ),
          );
        },
        child: widget.body,
      ),
    );
  }
}

/// A barrier that dims & ignore pointers of the underlaying child widget

class _ColoredBarrierLayer extends StatelessWidget {
  final ValueListenable<bool> activated;
  final Widget child;
  final AnimationController animation;
  final colorTween = ColorTween(begin: Colors.transparent, end: Colors.black54);

  _ColoredBarrierLayer(this.activated, {required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    final v = animation.drive(colorTween);
    return AnimatedBuilder(
      animation: v,
      builder: (context, body) {
        return Container(
          foregroundDecoration: BoxDecoration(color: v.value),
          child: body,
        );
      },
      child: IgnorePointer(ignoring: activated.value, child: child),
    );
  }
}

class _BottomAppBarContainer extends StatelessWidget {
  final ValueListenable<bool> expanded;
  final Widget child;
  final double height;

  const _BottomAppBarContainer(this.expanded, {required this.child, this.height = 500.0});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: expanded,
      builder: (_, __, ___) {
        return AnimatedContainer(
          curve: Curves.easeOutCirc,
          duration: _animDuration,
          height: expanded.value ? height : 48.0,
          child: expanded.value ? child : null,
        );
      },
    );
  }
}

class _CenterDockedButton extends StatelessWidget {
  final ValueNotifier<bool> expanded;
  final void Function(Uint8List img) onNewAvatar;
  final AnimationController animation;

  const _CenterDockedButton(this.expanded, {required this.animation, required this.onNewAvatar});

  @override
  Widget build(BuildContext context) {
    // avoid unneccessary object recreations
    final _avatar = Avatar(onNew: onNewAvatar);
    final _fab = FloatingActionButton(
      child: Icon(Icons.add),
      backgroundColor: RallyColors.buttonColor,
      onPressed: () => expanded.value = true,
    );

    return RadialMenu(
      width: 56.0,
      height: 56.0,
      duration: _animDuration,
      beginScale: 1.0,
      endScale: 1.8,
      animationController: animation,
      closedBuilder: (_, __) {
        return _fab;
      },
      openBuilder: (_, __) {
        return _avatar;
      },
    );
  }
}
