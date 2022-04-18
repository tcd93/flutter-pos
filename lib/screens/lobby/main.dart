import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../database_factory.dart';
import '../../storage_engines/connection_interface.dart';
import './table_icon.dart';
import '../../common/common.dart';
import '../../theme/rally.dart';
import '../../provider/src.dart';
import 'anim_longclick_fab.dart';

class LobbyScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // store previous index when adding tab
    final _prevIdx = useRef<int?>(null);

    // states
    final _maxTab = useState(0);
    _maxTab.value = context
        .select((ConfigSupplier? cs) => cs?.maxTab ?? 0); // "sync" internal state with repo changes

    // computed values
    final _tabs = useMemoized(
      () => [for (int i = 1; i <= _maxTab.value; i++) Tab(text: i.toString())],
      [_maxTab.value],
    );
    final _views = useMemoized(
      () => [for (int i = 0; i < _maxTab.value; i++) _InteractiveBody(i)],
      [_maxTab.value],
    );
    final _ticker = useSingleTickerProvider(keys: [_maxTab.value]);
    // for dynamic tab length to work, new controller need to be created every time a tab is added
    final _controller = useMemoized(
      () => TabController(length: _maxTab.value, vsync: _ticker),
      [_maxTab.value],
    );

    useEffect(() {
      // animate to new tab with the new controller
      if (_prevIdx.value != null) {
        _controller.index = _prevIdx.value!;
        _controller.animateTo(_maxTab.value - 1);
      }
      return;
    }, [_maxTab.value]);

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
        onLongPress: () => context.read<NodeSupplier>().addNode(_controller.index),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: TabBar(
          controller: _controller,
          isScrollable: true,
          tabs: _tabs,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _maxTab.value++;
              context.read<ConfigSupplier>().addTab();
              _prevIdx.value = _controller.index;
              _controller.dispose();
            },
          ),
        ],
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _controller,
        children: _views,
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
  /// The key to container (1)
  late GlobalKey bgKey;

  late TransformationController transformController;

  final _dragEndEvent = StreamController<Map<String, num>>.broadcast();

  @override
  void initState() {
    super.initState();
    bgKey = GlobalKey();
    transformController = TransformationController();
  }

  @override
  void dispose() {
    transformController.dispose();
    _dragEndEvent.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final supplier = Provider.of<NodeSupplier>(context, listen: true);
    return InteractiveViewer(
      maxScale: 2.0,
      transformationController: transformController,
      child: Stack(
        children: [
          // create a container (1) here to act as fixed background
          Container(key: bgKey),
          for (var node in supplier.nodes(widget.page))
            ChangeNotifierProvider(
              create: (_) {
                final database = context.read<DatabaseConnectionInterface?>();
                return OrderSupplier(
                  database: database != null
                      ? DatabaseFactory().createRIDRepository<Order>(database)
                      : null,
                );
              },
              child: DraggableWidget(
                x: node.x,
                y: node.y,
                onDragEnd: (x, y) {
                  supplier.updateNode(node);
                  _dragEndEvent.add({'id': node.id, 'x': x, 'y': y});
                },
                key: ObjectKey(node),
                child: TableIcon(
                  node: node,
                  containerKey: bgKey,
                  dragEndEventStream: _dragEndEvent.stream,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
