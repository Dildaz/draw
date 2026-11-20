import 'dart:convert';
import 'package:flutter/services.dart';

class LanguageOption {
  const LanguageOption({
    required this.code,
    required this.nativeName,
    required this.flagAsset,
  });

  final String code;
  final String nativeName;
  final String flagAsset;
}

const List<LanguageOption> kSupportedLanguages = [
  LanguageOption(code: 'en', nativeName: 'English', flagAsset: 'assets/images/flags/flag_gb.png'),
  LanguageOption(code: 'es', nativeName: 'Español', flagAsset: 'assets/images/flags/flag_es.png'),
  LanguageOption(code: 'pt', nativeName: 'Português', flagAsset: 'assets/images/flags/flag_pt.png'),
  LanguageOption(code: 'fr', nativeName: 'Français', flagAsset: 'assets/images/flags/flag_fr.png'),
  LanguageOption(code: 'de', nativeName: 'Deutsch', flagAsset: 'assets/images/flags/flag_de.png'),
  LanguageOption(code: 'vi', nativeName: 'Tiếng Việt', flagAsset: 'assets/images/flags/flag_vn.png'),
  LanguageOption(code: 'id', nativeName: 'Bahasa Indonesia', flagAsset: 'assets/images/flags/flag_id.png'),
];

class LocService {
  String _lang = 'en';
  Map<String, String> _table = const {};

  String get language => _lang;

  Future<void> setLanguage(String code) async {
    _lang = code;
    if (code == 'en') {
      _table = const {};
      return;
    }
    try {
      final raw = await rootBundle.loadString('assets/loc/$code.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _table = decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      _table = const {};
    }
  }

  String t(String key, [List<Object>? args]) {
    var text = _table[key] ?? key;
    if (args != null) {
      for (var i = 0; i < args.length; i++) {
        text = text.replaceAll('{$i}', args[i].toString());
      }
    }
    return text;
  }
}
