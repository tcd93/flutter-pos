import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../provider/src.dart';

class NodeAppBarTitle extends HookWidget {
  const NodeAppBarTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nodesWhereID = context.select((NodeSupplier ns) => ns.where);
    final node = context.select((OrderSupplier os) {
      assert(os.order.tableID != -1);
      return nodesWhereID(os.order.tableID);
    });
    if (node == null) return const SizedBox.shrink();

    final controller = useTextEditingController(text: node.name);

    return IntrinsicWidth(
      child: TextField(
        controller: controller,
        decoration: InputDecoration.collapsed(
          hintText: AppLocalizations.of(context)!.edit_menu_node,
          border: const UnderlineInputBorder(),
        ),
        textAlign: TextAlign.center,
        // [onSubmitted] currently not working on web, use [onChange] instead
        onChanged: (string) {
          node.name = string;
          context.read<NodeSupplier>().updateNode(node);
        },
      ),
    );
  }
}
