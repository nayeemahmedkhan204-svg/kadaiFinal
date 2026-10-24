import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'strings_en.dart';
import 'strings_ta.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ta', 'IN'),
  ];

  Map<String, String> get _strings {
    switch (locale.languageCode) {
      case 'ta':
        return stringsTa;
      case 'en':
      default:
        return stringsEn;
    }
  }

  String translate(String key) {
    return _strings[key] ?? key;
  }

  String get products => translate('products');

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ta'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US');
  Locale get locale => _locale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(AppConstants.keyAppLanguage) ?? 'en';
    _locale = Locale(lang);
    notifyListeners();
  }

  Future<void> setLocale(Locale loc) async {
    _locale = loc;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAppLanguage, loc.languageCode);
    notifyListeners();
  }
}
