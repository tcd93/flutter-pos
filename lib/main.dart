// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
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
      builder: (context, child) => Provider(
        create: (_) => OrderTracker(),
        child: child,
      ),
      routes: {
        '/': (context) => LobbyScreen(),
      },
    );
  }
}
