// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primarySwatch: Colors.yellow,
  primaryColor: Colors.yellow,
  primaryColorLight: Color.fromRGBO(255, 255, 230, 1),
  disabledColor: Colors.grey[200],
  fontFamily: 'Corben',
  textTheme: TextTheme(
    headline1: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 24,
      color: Colors.black,
    ),
    headline2: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
    headline3: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: Colors.black,
    ),
  ),
  iconTheme: IconThemeData(size: 30),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    foregroundColor: Color.fromRGBO(255, 51, 51, 0.8),
    backgroundColor: Colors.yellow,
  ),
  cardColor: Color.fromARGB(75, 192, 192, 192),
  pageTransitionsTheme: PageTransitionsTheme(
    builders: {
      TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
    },
  ),
);
