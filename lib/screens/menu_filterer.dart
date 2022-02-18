import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../provider/src.dart';
import 'debouncer.dart';

class MenuFilterer extends HookWidget {
  final _debouncer = Debouncer(milliseconds: 300);

  /// `menu` can be a filtered list or full list; rebuild upon changes notified on [MenuSupplier]
  final Widget Function(BuildContext context, List<Dish> menu) builder;

  MenuFilterer({required this.builder, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // states
    final filtering = useState<String?>(null);

    return SafeArea(
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(15.0),
              hintText: AppLocalizations.of(context)?.edit_menu_filterHint,
            ),
            onChanged: (string) {
              _debouncer.run(() {
                filtering.value = string;
              });
            },
          ),
          _MenuList(
            builder: (initialList) {
              final filterString = filtering.value;
              if (filterString == null || filterString.isEmpty) {
                return builder(context, initialList); // full list
              }
              final filteredList = useMemoized(() {
                return initialList
                    .where((u) => (u.dish.toLowerCase().contains(filterString.toLowerCase())))
                    .toList();
              }, [filtering.value, initialList]);
              return builder(context, filteredList);
            },
          ),
        ],
      ),
    );
  }
}

class _MenuList extends HookWidget {
  final Widget Function(List<Dish> initialList) builder;

  /// Return generic text 'No data found' or build a list of [_ListItem]
  const _MenuList({required this.builder});

  @override
  Widget build(BuildContext context) {
    final loading = context.select((MenuSupplier supplier) => supplier.loading);
    if (loading) {
      return const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      );
    }
    final dishes = context.select((MenuSupplier supplier) => supplier.menu.toList());
    if (dishes.isEmpty) {
      return Text(AppLocalizations.of(context)?.generic_empty ?? 'No data found');
    }
    return Expanded(child: builder(dishes));
  }
}
