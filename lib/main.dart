import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'theme/theme.dart';
import 'database_factory.dart';
import 'generated/l10n.dart';
import 'provider/src.dart';
import 'screens/order_details/main.dart';
import 'screens/edit_menu/main.dart';
import 'screens/history/main.dart';
import 'screens/lobby/main.dart';
import 'screens/menu/main.dart';
import 'storage_engines/connection_interface.dart';

void main() {
  final storage = DatabaseFactory().create('local-storage');

  runApp(PosApp(storage));
}

class PosApp extends StatelessWidget {
  final DatabaseConnectionInterface _storage;

  PosApp([this._storage]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: '',
      theme: appTheme,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      initialRoute: '/',
      builder: (_, screen) => FutureBuilder<dynamic>(
        future: _storage.open(),
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
        final argMap = settings.arguments as Map;
        final String heroTag = argMap != null ? argMap['heroTag'] : null;
        final TableModel model = argMap != null ? argMap['model'] : null;
        final String fromScreen = argMap != null ? argMap['from'] : null;

        switch (settings.name) {
          case '/menu':
            return routeBuilder(MenuScreen(model, fromHeroTag: heroTag));
            break;
          case '/order-details':
            final TableModel order = argMap != null ? argMap['state'] : null;
            return routeBuilder(
              DetailsScreen(
                order,
                fromHeroTag: heroTag,
                fromScreen: fromScreen,
              ),
            );
            break;
          case '/history':
            return routeBuilder(HistoryScreen(_storage));
            break;
          case '/edit-menu':
            return routeBuilder(EditMenuScreen());
            break;
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
