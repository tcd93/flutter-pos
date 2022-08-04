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
    final prevIdx = useRef<int?>(null);

    // states
    final maxTab = useState(0);
    maxTab.value = context
        .select((ConfigSupplier? cs) => cs?.maxTab ?? 0); // "sync" internal state with repo changes

    // computed values
    final tabs = useMemoized(
      () => [for (int i = 1; i <= maxTab.value; i++) Tab(text: i.toString())],
      [maxTab.value],
    );
    final views = useMemoized(
      () => [for (int i = 0; i < maxTab.value; i++) _InteractiveBody(i)],
      [maxTab.value],
    );
    final ticker = useSingleTickerProvider(keys: [maxTab.value]);
    // for dynamic tab length to work, new controller need to be created every time a tab is added
    final controller = useMemoized(
      () => TabController(length: maxTab.value, vsync: ticker),
      [maxTab.value],
    );

    useEffect(() {
      // animate to new tab with the new controller
      if (prevIdx.value != null) {
        controller.index = prevIdx.value!;
        controller.animateTo(maxTab.value - 1);
      }
      return;
    }, [maxTab.value]);

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
        onLongPress: () => context.read<NodeSupplier>().addNode(controller.index),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: TabBar(
          controller: controller,
          isScrollable: true,
          tabs: tabs,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              maxTab.value++;
              context.read<ConfigSupplier>().addTab();
              prevIdx.value = controller.index;
              controller.dispose();
            },
          ),
        ],
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: views,
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
              key: ObjectKey(node),
              create: (_) {
                final database = context.read<DatabaseConnectionInterface?>();
                return OrderSupplier(
                  database: database != null
                      ? DatabaseFactory().createRIDRepository<Order>(database)
                      : null,
                  order: Order.create(tableID: node.id),
                );
              },
              child: DraggableWidget(
                x: node.x,
                y: node.y,
                onDragEnd: (x, y) {
                  node.x = x;
                  node.y = y;
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
