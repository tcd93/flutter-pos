import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../avatar.dart';

const double height = 85.0;

@immutable
class Counter extends HookWidget {
  final _memoizer = AsyncMemoizer();
  final int startingValue;

  final ImageProvider? imgProvider;

  final String title;
  final String subtitle;
  final void Function(int currentValue) onIncrement;
  final void Function(int currentValue) onDecrement;

  Counter(
    this.startingValue, {
    required this.onIncrement,
    required this.onDecrement,
    this.imgProvider,
    required this.title,
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  int add(
    AnimationController animController,
    TextEditingController textEditingController,
    int value,
  ) {
    if (value == 0) animController.forward();

    value++;
    textEditingController.text = (value).toString();
    onIncrement(value);
    return value;
  }

  int sub(
    AnimationController animController,
    TextEditingController textEditingController,
    int value,
  ) {
    // animate to "start" color when back to 0
    if (value == 1) animController.reverse();

    if (value <= 0) return 0;

    value--;
    textEditingController.text = (value).toString();
    onDecrement(value);
    return value;
  }

  @override
  Widget build(BuildContext context) {
    // controllers
    final textEditingController =
        useTextEditingController(text: startingValue.toString());
    // "subscribe" to prop changes
    useEffect(() {
      textEditingController.text = startingValue.toString();
      return;
    }, [startingValue]);

    final animController =
        useAnimationController(duration: const Duration(milliseconds: 500));
    var value = int.parse(textEditingController.text);

    return AnimatedBuilder(
      animation: animController,
      builder: (context, child) {
        if (startingValue != 0) {
          _memoizer.runOnce(() {
            animController.forward();
          });
        }

        final colorTween = ColorTween(
          begin: Theme.of(context).cardTheme.color, // disabled color
          end: Theme.of(context).primaryColorLight, // hightlight if > 0
        );

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            SizedBox(
              height: height - 20.0,
              child: Card(
                margin: const EdgeInsets.only(left: height - 20.0),
                color: colorTween.animate(animController).value,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () =>
                      value = add(animController, textEditingController, value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 2.0, vertical: 4.0),
                    child: Row(
                      children: [
                        const Spacer(),
                        Expanded(
                          flex: 7,
                          child: ListTile(
                            minVerticalPadding: 2.0,
                            horizontalTitleGap: 2.0,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            title: Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            subtitle: Text(subtitle),
                          ),
                        ),
                        Expanded(
                          child: FloatingActionButton(
                            // decrease
                            heroTag: null,
                            onPressed: () => value = sub(
                                animController, textEditingController, value),
                            child: const Icon(Icons.remove),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: textEditingController,
                            enabled: false,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Expanded(
                          child: FloatingActionButton(
                            // increase
                            heroTag: null,
                            onPressed: () => value = add(
                                animController, textEditingController, value),
                            child: const Icon(Icons.add),
                          ),
                        ),
                        const SizedBox(width: 2.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: height,
              width: height,
              margin: const EdgeInsets.only(left: 2.0),
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                shadows: [
                  BoxShadow(
                    color: Theme.of(context).primaryColorLight,
                    blurRadius: animController.value * 6,
                    spreadRadius: animController.value * 9,
                  ),
                ],
              ),
              child: child,
            ),
          ],
        );
      },
      child: Avatar(imgProvider: imgProvider),
    );
  }
}
