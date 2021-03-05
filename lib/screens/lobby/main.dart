import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './table_icon.dart';
import '../../common/common.dart';
import '../../theme/rally.dart';
import '../../provider/src.dart';
import 'anim_longclick_fab.dart';

class LobbyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Tooltip(
              message: AppLocalizations.of(context)!.lobby_report,
              child: MaterialButton(
                onPressed: () => Navigator.pushNamed(context, '/history'),
                minWidth: MediaQuery.of(context).size.width / 2,
                child: Icon(Icons.history),
                shape: CustomShape(side: CustomShapeSide.left),
              ),
            ),
            Text(''),
            Tooltip(
              message: AppLocalizations.of(context)!.lobby_menuEdit,
              child: MaterialButton(
                onPressed: () => Navigator.pushNamed(context, '/edit-menu'),
                minWidth: MediaQuery.of(context).size.width / 2,
                child: Icon(Icons.menu_book_sharp),
                shape: CustomShape(side: CustomShapeSide.right),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: AnimatedLongClickableFAB(
        onLongPress: () => _addTable(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: _InteractiveBody(),
    );
  }
}

/// Allow panning & dragging widgets inside...
class _InteractiveBody extends StatelessWidget {
  /// The key to container (1), must be passed into all DraggableWidget widgets in Stack
  final GlobalKey bgKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final supplier = Provider.of<Supplier>(context, listen: true);
    return InteractiveViewer(
      maxScale: 2.0,
      child: Stack(
        children: [
          // create a container (1) here to act as fixed background for the entire screen,
          // pan & scale effect from InteractiveViewer will actually interact with this container
          // thus also easily scale & pan all widgets inside the stack
          Container(key: bgKey),
          for (var model in supplier.tables)
            DraggableWidget(
              child: TableIcon(table: model),
              x: model.getOffset().x,
              y: model.getOffset().y,
              containerKey: bgKey,
              onDragEnd: (x, y) {
                model.setOffset(Coordinate(x, y), supplier);
              },
              key: ObjectKey(model),
            ),
        ],
      ),
    );
  }
}

// ******************************* //

void _addTable(BuildContext context) {
  var supplier = Provider.of<Supplier>(context, listen: false);
  supplier.addTable();
}
