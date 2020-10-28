// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primarySwatch: Colors.yellow,
  textTheme: TextTheme(
    headline1: TextStyle(
      fontFamily: 'Corben',
      fontWeight: FontWeight.w700,
      fontSize: 24,
      color: Colors.black,
    ),
  ),
  iconTheme: IconThemeData(size: 30),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    foregroundColor: Colors.yellow[250],
    backgroundColor: Colors.green[300],
  ),
  cardColor: Color.fromARGB(75, 192, 192, 192),
);
