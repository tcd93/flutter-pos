import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../common/common.dart';
import '../avatar.dart';
import 'menu_form.dart';

const Duration _animDuration = Duration(milliseconds: 600);

/// Custom [Scaffold] with [AnimatedContainer] as bottomNavigationBar &
/// a centered FAB which can add new dish to menu list.
///
/// When FAB's clicked, the entire bottom appbar will animate up (like a bottom sheet)
/// showing a menu-add form.
class CustomScaffold extends HookWidget {
  final Widget body;

  /// called when user press the central FAB in bottom appbar
  final void Function(String name, double price, [Uint8List? image]) onAddDish;

  const CustomScaffold({required this.body, required this.onAddDish});

  @override
  Widget build(BuildContext context) {
    // controllers
    final animController = useAnimationController(duration: _animDuration);
    final expanded = useState(false);
    useEffect(() {
      expanded.value ? animController.forward() : animController.reverse();
      return;
    }, [expanded.value]);
    final dishNameController = useTextEditingController();
    final priceController = useTextEditingController();

    // state
    final pickedImage = useState<Uint8List?>(null);
    useEffect(() {
      dishNameController.clear();
      priceController.clear();
      return;
    }, [pickedImage.value]);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 6.0,
        child: _BottomAppBarContainer(
          expanded,
          child: Padding(
            padding: const EdgeInsets.only(top: 70.0, left: 70.0, right: 70.0),
            child: WillPopScope(
              onWillPop: () async {
                expanded.value = false;
                return false;
              },
              child: FormContent(
                inputs: buildInputs(context, dishNameController, priceController),
                onSubmit: () {
                  if (priceController.text.isNotEmpty && dishNameController.text.isNotEmpty) {
                    onAddDish(
                      dishNameController.text,
                      Money.unformat(priceController.text).toDouble(),
                      pickedImage.value,
                    );
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
        onNewAvatar: (img) => pickedImage.value = img,
        pickedImage: pickedImage.value,
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
              animation: animController,
              child: body!,
            ),
          );
        },
        child: body,
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
  final double height = 500;

  const _BottomAppBarContainer(this.expanded, {required this.child});

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
  final Uint8List? pickedImage;

  const _CenterDockedButton(
    this.expanded, {
    required this.animation,
    required this.onNewAvatar,
    this.pickedImage,
  });

  @override
  Widget build(BuildContext context) {
    // avoid unneccessary object recreations
    final avatar = Avatar(
      onNew: onNewAvatar,
      imgProvider: pickedImage != null ? MemoryImage(pickedImage!) : null,
    );
    final fab = FloatingActionButton(
      onPressed: () => expanded.value = true,
      child: const Icon(Icons.add),
    );

    return RadialMenu(
      width: 56.0,
      height: 56.0,
      duration: _animDuration,
      beginScale: 1.0,
      endScale: 1.8,
      animationController: animation,
      closedBuilder: (_, __) {
        return fab;
      },
      openBuilder: (_, __) {
        return avatar;
      },
    );
  }
}
