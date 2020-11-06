import 'package:flutter/material.dart';

const Color _darkPrimary = Colors.black;
const Color _darkAccent = Colors.white;
const Color _lightBG = Color(0xfffcfcff);
const Color _darkBG = Colors.black87;
final Color _focusColor = Colors.blueGrey[300];

final appTheme = ThemeData(
  fontFamily: 'Charmonman',
  brightness: Brightness.dark,
  backgroundColor: _darkBG,
  primaryColor: _darkPrimary,
  accentColor: _darkAccent,
  scaffoldBackgroundColor: _darkBG,
  appBarTheme: AppBarTheme(
    elevation: 0,
    textTheme: TextTheme(
      headline6: TextStyle(
        color: _lightBG,
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: _lightBG,
    focusColor: _focusColor,
    focusElevation: 18.0,
    splashColor: _focusColor,
  ),
);
