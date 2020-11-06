import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/theme.dart';

import 'models/tracker.dart';

import 'screens/details.dart';
import 'screens/lobby.dart';
import 'screens/menu.dart';

void main() {
  runApp(HemBoApp());
}

class HemBoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hem Bo Demo',
      theme: appTheme,
      initialRoute: '/',
      builder: (context, child) => ChangeNotifierProvider(
        create: (_) => OrderTracker(),
        child: child,
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
