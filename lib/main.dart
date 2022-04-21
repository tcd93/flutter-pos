import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'theme/theme.dart';
import 'database_factory.dart';
import 'provider/src.dart';
import 'screens/edit_menu/main.dart';
import 'screens/history/main.dart';
import 'screens/expense_journal/main.dart';
import 'screens/lobby/main.dart';
import 'storage_engines/connection_interface.dart';

void main() {
  final storage = DatabaseFactory().create(kIsWeb ? 'local-storage' : 'sqlite');
  final configStorage = DatabaseFactory().create('local-storage');
  WidgetsFlutterBinding.ensureInitialized();

  runApp(PosApp(storage, configStorage));
}

class PosApp extends StatelessWidget {
  final DatabaseConnectionInterface _storage, _configStorage;
  final Future _init;

  PosApp(this._storage, this._configStorage)
      : _init = Future.wait([_storage.open(), _configStorage.open()]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: '',
      theme: appTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: '/',
      builder: (_, screen) => FutureBuilder<dynamic>(
        future: _init,
        builder: (_, dbSnapshot) {
          if (dbSnapshot.hasData) {
            return MultiProvider(
              providers: [
                Provider.value(value: _storage),
                FutureProvider(
                  create: (_) => ConfigSupplier(
                    database: DatabaseFactory().createRIUDRepository<Config>(_configStorage),
                  ).init(),
                  initialData: null,
                  lazy: false,
                ),
                ChangeNotifierProvider(
                  create: (_) => NodeSupplier(
                    database: DatabaseFactory().createRIUDRepository<Node>(_storage),
                  ),
                ),
                ChangeNotifierProvider(
                  create: (_) => MenuSupplier(
                    database: DatabaseFactory().createRIUDRepository<Dish>(_storage),
                  ),
                  lazy: false,
                ),
              ],
              child: screen,
            );
          } else {
            return const Center(
              child: SizedBox(
                width: 40.0,
                height: 40.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            );
          }
        },
      ),
      home: LobbyScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/history':
            return routeBuilder(
              DefaultTabController(
                length: 2,
                child: ChangeNotifierProvider(
                  create: (_) => HistoryOrderSupplier(
                    database: DatabaseFactory().createRIDRepository<Order>(_storage),
                  ),
                  child: HistoryScreen(),
                ),
              ),
            );
          case '/expense':
            return routeBuilder(
              ChangeNotifierProvider(
                create: (_) {
                  return ExpenseSupplier(
                    database: DatabaseFactory().createRIRepository<Journal>(_storage),
                  );
                },
                child: ExpenseJournalScreen(),
              ),
            );
          case '/edit-menu':
            return routeBuilder(EditMenuScreen());
          default:
            return MaterialPageRoute(builder: (context) => const Center(child: Text('404')));
        }
      },
    );
  }
}

MaterialPageRoute routeBuilder(Widget screen) => MaterialPageRoute(
      builder: (_) => screen,
      maintainState: true,
    );
