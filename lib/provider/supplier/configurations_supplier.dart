import 'dart:async';

import '../../storage_engines/connection_interface.dart';

import '../src.dart';

class ConfigSupplier {
  late final List<Config> _configs;
  List<Config> get configs => List.unmodifiable(_configs);

  final Completer<ConfigSupplier> _completer = Completer();

  final RIUDRepository<Config>? database;

  ConfigSupplier({this.database, List<Config>? mock}) {
    if (mock != null) {
      _configs = mock;
      _completer.complete(this);
      return;
    }
    Future(() async {
      final cfg = (await database?.get()) ?? [];
      _configs = [for (final c in cfg) Config(key: c.key, value: c.value)];
      _completer.complete(this);
    });
  }

  Future<ConfigSupplier> init() async => await _completer.future;

  int get maxTab => _configs
      .firstWhere(
        (c) => c.key == 'maxTab',
        orElse: () => Config(key: 'maxTab', value: 1),
      )
      .value as int;

  Future<void> addTab() async {
    final config = Config(key: 'maxTab', value: maxTab + 1);
    final currIdx = _configs.indexWhere((c) => c.key == 'maxTab');
    if (currIdx != -1) {
      _configs[currIdx] = config;
    } else {
      _configs.add(config);
    }
    return database?.upsert(config);
  }
}
