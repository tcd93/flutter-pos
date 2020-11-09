import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/theme.dart';

import 'database_factory.dart';
import 'models/tracker.dart';

import 'screens/details.dart';
import 'screens/lobby.dart';
import 'screens/menu.dart';

void main() {
  final factory = DatabaseFactory('local-storage');

  runApp(HemBoApp(factory.storage()));
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
              create: (_) => OrderTracker(),
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
        final String heroTag = argMap['heroTag'];
        final int tableID = argMap['tableID'];

        if (settings.name == '/menu') {
          // custom page transition animations
          return routeBuilder(MenuScreen(tableID, fromHeroTag: heroTag));
        } else if (settings.name == '/order-details') {
          return routeBuilder(DetailsScreen(tableID, fromHeroTag: heroTag));
        }
        // unknown route
        return MaterialPageRoute(
            builder: (context) => Center(child: Text('404')));
      },
    );
  }
}

MaterialPageRoute routeBuilder(Widget screen) => MaterialPageRoute(
      builder: (_) => screen,
      maintainState: false,
    );
