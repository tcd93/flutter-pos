import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'theme/theme.dart';
import 'database_factory.dart';
import 'provider/src.dart';
import 'screens/order_details/main.dart';
import 'screens/edit_menu/main.dart';
import 'screens/history/main.dart';
import 'screens/lobby/main.dart';
import 'screens/menu/main.dart';
import 'storage_engines/connection_interface.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = DatabaseFactory().create('local-storage');

  runApp(PosApp(storage));
}

class PosApp extends StatelessWidget {
  final DatabaseConnectionInterface _storage;
  final Future _init;

  PosApp(this._storage)
      : _init = Future.wait([
          _storage.open(),
          Menu().load(),
        ], eagerError: true);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: '',
      theme: appTheme,
      localizationsDelegates: [
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
            return ChangeNotifierProvider(
              create: (_) => Supplier(database: _storage),
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
        final argMap = settings.arguments as Map?;
        final String heroTag = argMap != null ? argMap['heroTag'] ?? '' : '';

        switch (settings.name) {
          case '/menu':
            final TableModel model = argMap!['model'];
            return routeBuilder(MenuScreen(model, fromHeroTag: heroTag));
          case '/order-details':
            final TableModel order = argMap!['state'];
            final String fromScreen = argMap['from'] ?? '';

            return routeBuilder(
              DetailsScreen(
                order,
                fromHeroTag: heroTag,
                fromScreen: fromScreen,
              ),
            );
          case '/history':
            return routeBuilder(HistoryScreen(_storage));
          case '/edit-menu':
            return routeBuilder(EditMenuScreen());
          default:
            return MaterialPageRoute(builder: (context) => Center(child: Text('404')));
        }
      },
    );
  }
}

MaterialPageRoute routeBuilder(Widget screen) => MaterialPageRoute(
      builder: (_) => screen,
      maintainState: true,
    );
