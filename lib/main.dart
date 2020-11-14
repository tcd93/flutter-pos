import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/theme.dart';

import 'database_factory.dart';
import 'models/supplier.dart';

import 'screens/details.dart';
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
        final int tableID = argMap != null ? argMap['tableID'] : null;

        if (settings.name == '/menu') {
          // custom page transition animations
          return routeBuilder(MenuScreen(tableID, fromHeroTag: heroTag));
        } else if (settings.name == '/order-details') {
          return routeBuilder(DetailsScreen(tableID, fromHeroTag: heroTag));
        } else if (settings.name == '/history') {
          return routeBuilder(HistoryScreen(_storage));
        }
        // unknown route
        return MaterialPageRoute(builder: (context) => Center(child: Text('404')));
      },
    );
  }
}

MaterialPageRoute routeBuilder(Widget screen) => MaterialPageRoute(
      builder: (_) => screen,
      maintainState: false,
    );
