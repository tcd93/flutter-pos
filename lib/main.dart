import 'package:flutter/material.dart';
import 'package:hembo/screens/menu.dart';
import 'package:provider/provider.dart';
import './common/theme.dart';
import 'models/order.dart';
import 'screens/lobby.dart';

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
        if (settings.name == '/menu') {
          final String heroTag = settings.arguments;
          // custom page transition animations
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => MenuScreen(fromHeroTag: heroTag),
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
        }
        // unknown route
        return MaterialPageRoute(builder: (context) => Center(child: Text('404')));
      },
    );
  }
}
