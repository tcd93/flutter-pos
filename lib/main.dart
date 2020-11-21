import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/theme.dart';
import 'database_factory.dart';
import 'models/supplier.dart';
import 'models/table.dart';
import 'screens/details.dart';
import 'screens/edit_menu.dart';
import 'screens/history.dart';
import 'screens/lobby.dart';
import 'screens/menu.dart';
import 'storage_engines/connection_interface.dart';

void main() {
  final storage = DatabaseFactory().create('local-storage');

  runApp(HemBoApp(storage));
}

class HemBoApp extends StatelessWidget {
  final DatabaseConnectionInterface _storage;

  HemBoApp([this._storage]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hem Bo Demo',
      theme: appTheme,
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
            return routeBuilder(
              DetailsScreen(
                model,
                fromHeroTag: heroTag,
                fromScreen: fromScreen,
              ),
            );
            break;
          case '/history':
            return routeBuilder(HistoryScreen(_storage));
            break;
          case '/edit-menu':
            return routeBuilder(EditMenuScreen()); // TODO: persist changes to menu price, discount
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
