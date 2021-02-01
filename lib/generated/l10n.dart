// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `POS app`
  String get main_title {
    return Intl.message(
      'POS app',
      name: 'main_title',
      desc: '',
      args: [],
    );
  }

  /// `Delete?`
  String get generic_deleteQuestion {
    return Intl.message(
      'Delete?',
      name: 'generic_deleteQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get generic_yes {
    return Intl.message(
      'Yes',
      name: 'generic_yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get generic_no {
    return Intl.message(
      'No',
      name: 'generic_no',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get generic_confirm {
    return Intl.message(
      'Confirm',
      name: 'generic_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get generic_cancel {
    return Intl.message(
      'Cancel',
      name: 'generic_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Lobby`
  String get lobby {
    return Intl.message(
      'Lobby',
      name: 'lobby',
      desc: '',
      args: [],
    );
  }

  /// `Simple POS`
  String get lobby_drawerHeader {
    return Intl.message(
      'Simple POS',
      name: 'lobby_drawerHeader',
      desc: '',
      args: [],
    );
  }

  /// `Report`
  String get lobby_report {
    return Intl.message(
      'Report',
      name: 'lobby_report',
      desc: '',
      args: [],
    );
  }

  /// `Edit menu`
  String get lobby_menuEdit {
    return Intl.message(
      'Edit menu',
      name: 'lobby_menuEdit',
      desc: '',
      args: [],
    );
  }

  /// `Long tap to add table`
  String get lobby_tooltip {
    return Intl.message(
      'Long tap to add table',
      name: 'lobby_tooltip',
      desc: '',
      args: [],
    );
  }

  /// `Discount`
  String get details_discount {
    return Intl.message(
      'Discount',
      name: 'details_discount',
      desc: '',
      args: [],
    );
  }

  /// `Total: {total}, discounted: {discountPct}%`
  String details_discountTxt(Object total, Object discountPct) {
    return Intl.message(
      'Total: $total, discounted: $discountPct%',
      name: 'details_discountTxt',
      desc: '',
      args: [total, discountPct],
    );
  }

  /// `(deleted)`
  String get details_liDeleted {
    return Intl.message(
      '(deleted)',
      name: 'details_liDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Customer pay`
  String get details_customerPay {
    return Intl.message(
      'Customer pay',
      name: 'details_customerPay',
      desc: '',
      args: [],
    );
  }

  /// `Not enough`
  String get details_notEnough {
    return Intl.message(
      'Not enough',
      name: 'details_notEnough',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Order`
  String get menu_confirm {
    return Intl.message(
      'Confirm Order',
      name: 'menu_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Undo`
  String get menu_undo {
    return Intl.message(
      'Undo',
      name: 'menu_undo',
      desc: '',
      args: [],
    );
  }

  /// `Filter by dish name..`
  String get edit_menu_filterHint {
    return Intl.message(
      'Filter by dish name..',
      name: 'edit_menu_filterHint',
      desc: '',
      args: [],
    );
  }

  /// `Dish`
  String get edit_menu_formLabel {
    return Intl.message(
      'Dish',
      name: 'edit_menu_formLabel',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get edit_menu_formPrice {
    return Intl.message(
      'Price',
      name: 'edit_menu_formPrice',
      desc: '',
      args: [],
    );
  }

  /// `Ignore this order?`
  String get history_delPopUpTitle {
    return Intl.message(
      'Ignore this order?',
      name: 'history_delPopUpTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select range`
  String get history_rangePickerHelpTxt {
    return Intl.message(
      'Select range',
      name: 'history_rangePickerHelpTxt',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'vi', countryCode: 'VN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}