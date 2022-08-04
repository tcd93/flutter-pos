import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/common.dart';
import '../../theme/rally.dart';
import '../../provider/src.dart';
import '../menu/main.dart';
import '../order_details/main.dart';
import '../popup_del.dart';

enum _Position {
  topLeft,
  left,
  bottomLeft,
  bottom,
  bottomRight,
  right,
  topRight,
  top,
  center,

  outside,
  unknown,
}

class TableIcon extends StatefulWidget {
  final Node node;

  /// See [DraggableWidget.containerKey]
  final GlobalKey? containerKey;
  final Stream<Map<String, num>>? dragEndEventStream;

  const TableIcon({
    required this.node,
    this.containerKey,
    this.dragEndEventStream,
  });

  @override
  State<TableIcon> createState() => _TableIconState();
}

class _TableIconState extends State<TableIcon> {
  late Size size;
  var position = _Position.unknown;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      size = (context.findRenderObject() as RenderBox).size;
      determineOrientation({'id': widget.node.id, 'x': widget.node.x, 'y': widget.node.y});
    });
    widget.dragEndEventStream?.listen(determineOrientation);
  }

  @override
  void dispose() {
    widget.dragEndEventStream?.drain();
    super.dispose();
  }

  void determineOrientation(Map<String, num> event) {
    if (event['id'] != widget.node.id) return;

    final bgRenderObject = widget.containerKey?.currentContext?.findRenderObject();
    if (bgRenderObject == null) return;

    final bgRenderBox = bgRenderObject as RenderBox;
    final centerX = event['x']! + size.height / 2; // the X pos at this element's center point
    final centerY = event['y']! + size.width / 2; // the Y pos at this element's center point
    const bandWidth = 140;

    setState(() {
      if (centerX - bandWidth <= 0 && centerX >= 0) {
        if (centerY - bandWidth <= 0 && centerY >= 0) {
          position = _Position.topLeft;
        } else if (centerY - bandWidth >= 0 && centerY + bandWidth <= bgRenderBox.size.height) {
          position = _Position.left;
        } else {
          position = _Position.bottomLeft;
        }
      } else if (centerX - bandWidth >= 0 && centerX + bandWidth <= bgRenderBox.size.width) {
        if (centerY - bandWidth <= 0 && centerY >= 0) {
          position = _Position.top;
        } else if (centerY - bandWidth >= 0 && centerY + bandWidth <= bgRenderBox.size.height) {
          position = _Position.center;
        } else {
          position = _Position.bottom;
        }
      } else if (centerX + bandWidth >= bgRenderBox.size.width &&
          centerX <= bgRenderBox.size.width) {
        if (centerY - bandWidth <= 0 && centerY >= 0) {
          position = _Position.topRight;
        } else if (centerY - bandWidth >= 0 && centerY + bandWidth <= bgRenderBox.size.height) {
          position = _Position.right;
        } else {
          position = _Position.bottomRight;
        }
      } else {
        position = _Position.outside;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<double> angles = [0, 90, 180];
    switch (position) {
      case _Position.topLeft:
        angles = [0, 45, 90];
        break;
      case _Position.left:
        angles = [-90, 0, 90];
        break;
      case _Position.bottomLeft:
        angles = [0, -45, -90];
        break;
      case _Position.bottom:
        angles = [0, -90, -180];
        break;
      case _Position.topRight:
        angles = [-180, -225, -270];
        break;
      case _Position.right:
        angles = [-90, -180, -270];
        break;
      case _Position.bottomRight:
        angles = [-180, -135, -90];
        break;
      default:
        angles = [0, 90, 180];
    }

    return Padding(
      padding: const EdgeInsets.all(15),
      child: _RadialButton(
        widget.node,
        surroundingButtonsBuilder: (context, animController) =>
            _build(context, animController, angles),
      ),
    );
  }

  /// `angles`: Clock-wise placement angles for surrounding sub-buttons (add order, details...).
  ///
  /// Example: `[0, 90]` would place one at 3 o'clock, the other at 6 o'clock
  List<Widget> _build(
    BuildContext context,
    AnimationController radialAnimationController,
    List<double> angles,
  ) {
    final supplier = Provider.of<OrderSupplier>(context);
    return [
      // add order
      DrawerItem(
        controller: radialAnimationController,
        angle: angles[0],
        key: const ValueKey<int>(1),
        child: FloatingActionButton(
          mini: true,
          heroTag: 'menu-subtag-table-${widget.node.id}',
          onPressed: () {
            // since order provider are not placed at the root, named route changing will make it
            // loses value
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return ChangeNotifierProvider.value(
                  value: supplier,
                  child: MenuScreen(fromHeroTag: 'menu-subtag-table-${widget.node.id}'),
                );
              },
            )).then((_) {
              Future.delayed(
                const Duration(milliseconds: 600),
                () => radialAnimationController.reverse(),
              );
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
      // see order details (and checkout)
      DrawerItem(
        controller: radialAnimationController,
        angle: angles[1],
        key: const ValueKey<int>(2),
        child: FloatingActionButton(
          mini: true,
          heroTag: 'details-subtag-table-${widget.node.id}',
          onPressed: supplier.order.status == TableStatus.occupied
              ? () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return ChangeNotifierProvider.value(
                        value: supplier,
                        child: DetailsScreen(
                          fromHeroTag: 'details-subtag-table-${widget.node.id}',
                          fromScreen: 'lobby',
                        ),
                      );
                    },
                  )).then((_) {
                    Future.delayed(
                      const Duration(milliseconds: 600),
                      () => radialAnimationController.reverse(),
                    );
                  });
                }
              : null,
          backgroundColor: supplier.order.status == TableStatus.occupied ? null : RallyColors.gray,
          child: const Icon(Icons.receipt),
        ),
      ),
      // remove table node
      DrawerItem(
        controller: radialAnimationController,
        angle: angles[2],
        key: const ValueKey<int>(3),
        child: FloatingActionButton(
          mini: true,
          heroTag: 'delete-subtag-table-${widget.node.id}',
          onPressed: () => _removeNode(context, widget.node),
          child: const Icon(Icons.delete),
        ),
      ),
    ];
  }
}

class _RadialButton extends StatelessWidget {
  final Node node;

  final List<Widget> Function(BuildContext, AnimationController) surroundingButtonsBuilder;

  const _RadialButton(
    this.node, {
    required this.surroundingButtonsBuilder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final order = context.select((OrderSupplier supplier) => supplier.order);
    final colorTween = ColorTween(
      begin: order.status == TableStatus.occupied
          ? Colors.yellow[300]
          : order.status == TableStatus.incomplete
              ? Colors.grey[500]
              : Theme.of(context).floatingActionButtonTheme.backgroundColor,
      end: RallyColors.focusColor,
    );

    return RadialMenu(
      closedBuilder: (radialAnimationController, context) {
        return FloatingActionButton(
          heroTag: null,
          mini: true,
          onPressed: () {
            radialAnimationController.forward();
          },
          backgroundColor: colorTween.animate(radialAnimationController).value,
          child: Text(node.id.toString()),
        );
      },
      openBuilder: (radialAnimationController, context) {
        return FloatingActionButton(
          heroTag: null,
          mini: true,
          onPressed: () {
            radialAnimationController.reverse();
          },
          backgroundColor: colorTween.animate(radialAnimationController).value,
          child: const Icon(Icons.circle),
        );
      },
      drawerBuilder: (context, animController) =>
          surroundingButtonsBuilder(context, animController),
    );
  }
}

// ******************************* //

void _removeNode(BuildContext context, Node node) async {
  final supplier = Provider.of<NodeSupplier>(context, listen: false);
  var delete = await popUpDelete(context);
  if (delete != null && delete) {
    supplier.removeNode(node);
  }
}
