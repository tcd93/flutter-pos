import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './table_icon.dart';
import '../../common/common.dart';
import '../../theme/rally.dart';
import '../../provider/src.dart';
import 'anim_longclick_fab.dart';

class LobbyScreen extends StatefulWidget {
  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> with TickerProviderStateMixin {
  late TabController _controller;
  late List<Tab> _tabs;
  late List<_InteractiveBody> _views;
  int maxTab = 1;

  @override
  void initState() {
    _controller = TabController(length: maxTab, vsync: this);
    _tabs = [for (int i = 1; i <= maxTab; i++) Tab(text: i.toString())];
    _views = [for (int i = 1; i <= maxTab; i++) _InteractiveBody(i - 1)];
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Tooltip(
              message: AppLocalizations.of(context)?.lobby_report ?? 'Report',
              child: MaterialButton(
                onPressed: () {
                  showBottomSheetMenu(context);
                },
                minWidth: MediaQuery.of(context).size.width / 2,
                shape: const CustomShape(side: CustomShapeSide.left),
                child: const Icon(Icons.menu),
              ),
            ),
            Tooltip(
              message: AppLocalizations.of(context)?.lobby_menuEdit ?? 'Edit Menu',
              child: MaterialButton(
                onPressed: () => Navigator.pushNamed(context, '/edit-menu'),
                minWidth: MediaQuery.of(context).size.width / 2,
                shape: const CustomShape(side: CustomShapeSide.right),
                child: const Icon(Icons.menu_book_sharp),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: AnimatedLongClickableFAB(
        onLongPress: () => context.read<Supplier>().addTable(_controller.index),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: TabBar(
          controller: _controller,
          isScrollable: true,
          tabs: _tabs,
          key: ObjectKey(maxTab), // see issue #20292 for dynamic tabbar length bug
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              int currIdx = _controller.index;
              _controller.dispose();

              setState(() {
                ++maxTab;
                _tabs.add(Tab(text: maxTab.toString()));
                _views.add(_InteractiveBody(maxTab - 1));
                _controller = TabController(length: maxTab, vsync: this);
                _controller.index = currIdx;
                _controller.animateTo(maxTab - 1);
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _controller,
        children: _views,
        key: ObjectKey(maxTab), // see issue #20292 for dynamic tabbar length bug
      ),
    );
  }

  Future showBottomSheetMenu(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      // isScrollControlled combined with shrinkWrap for minimal height in bottom sheet
      isScrollControlled: true,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context)?.lobby_report.toUpperCase() ?? 'HISTORY',
                textAlign: TextAlign.center,
              ),
              onTap: () => Navigator.pushNamed(context, '/history'),
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)?.lobby_journal.toUpperCase() ?? 'EXPENSE JOURNAL',
                textAlign: TextAlign.center,
              ),
              onTap: () => Navigator.pushNamed(context, '/expense'),
            ),
          ],
        );
      },
    );
  }
}

/// Allow panning & dragging widgets inside...
class _InteractiveBody extends StatefulWidget {
  final int page;

  _InteractiveBody(this.page) : super(key: ObjectKey(page));

  @override
  State<_InteractiveBody> createState() => _InteractiveBodyState();
}

class _InteractiveBodyState extends State<_InteractiveBody>
    with AutomaticKeepAliveClientMixin<_InteractiveBody> {
  /// The key to container (1), must be passed into all DraggableWidget widgets in Stack
  late GlobalKey bgKey;

  late TransformationController transformController;

  @override
  void initState() {
    bgKey = GlobalKey();
    transformController = TransformationController();
    super.initState();
  }

  @override
  void dispose() {
    transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final supplier = Provider.of<Supplier>(context, listen: true);
    return InteractiveViewer(
      maxScale: 2.0,
      transformationController: transformController,
      child: Stack(
        children: [
          // create a container (1) here to act as fixed background for the entire screen,
          // pan & scale effect from InteractiveViewer will actually interact with this container
          // thus also easily scale & pan all widgets inside the stack
          Container(key: bgKey),
          for (var model in supplier.tables(widget.page))
            DraggableWidget(
              x: model.getOffset()['x']!,
              y: model.getOffset()['y']!,
              containerKey: bgKey,
              transformController: transformController,
              onDragEnd: (x, y) {
                model.setOffset(x, y, supplier.database);
              },
              key: ObjectKey(model),
              child: TableIcon(table: model),
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
