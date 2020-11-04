import 'package:flutter/material.dart';
import 'package:hembo/screens/details.dart';
import 'package:provider/provider.dart';
import './common/theme.dart';
import 'models/tracker.dart';
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
        return MaterialPageRoute(builder: (context) => Center(child: Text('404')));
      },
    );
  }
}

PageRouteBuilder routeBuilder(Widget screen) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
            position: animation
                .drive(CurveTween(curve: Curves.easeOutCirc))
                .drive<Offset>(Tween(begin: Offset(0, 1), end: Offset.zero)),
            child: FadeTransition(
              opacity: animation.drive<double>(CurveTween(curve: Curves.easeOut)),
              child: child,
            ));
      },
      transitionDuration: Duration(milliseconds: 600),
      reverseTransitionDuration: Duration(milliseconds: 600),
    );
