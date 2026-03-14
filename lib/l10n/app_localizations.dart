import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Future<bool> load() async {
    final String jsonString = await rootBundle.loadString('lib/l10n/app_translations.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final langCode = locale.languageCode;
    final Map<String, dynamic>? langMap = jsonMap[langCode] ?? jsonMap['en'];
    _localizedStrings = langMap?.map((key, value) => MapEntry(key, value.toString())) ?? {};
    return true;
  }

  String translate(String key, {Map<String, String>? params}) {
    String? value = _localizedStrings[key];
    if (value == null) return key;
    if (params != null) {
      params.forEach((k, v) {
        value = value!.replaceAll('{$k}', v);
      });
    }
    return value!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => [
    'en', 'xh', 'zu', 'nr', 've', 'af'
  ].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
