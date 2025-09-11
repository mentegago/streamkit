import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:tuple/tuple.dart';

abstract class LanguageDetectionService {
  Language getLanguage(
    String text, {
    required Set<Language> whitelistedLanguages,
  });
}

class AppLanguageDetectionService implements LanguageDetectionService {
  static Map<String, dynamic> enModel = {};
  static Map<String, dynamic> idModel = {};
  static Map<String, dynamic> frModel = {};

  AppLanguageDetectionService() {
    _loadLanguageModels();
  }

  void _loadLanguageModels() async {
    final String enJsonString =
        await rootBundle.loadString("assets/en_ngram_model.json");
    final String idJsonString =
        await rootBundle.loadString("assets/id_ngram_model.json");
    final String frJsonString =
        await rootBundle.loadString("assets/fr_ngram_model.json");

    enModel = json.decode(enJsonString);
    idModel = json.decode(idJsonString);
    frModel = json.decode(frJsonString);
  }

  @override
  Language getLanguage(
    String text, {
    required Set<Language> whitelistedLanguages,
  }) {
    if (whitelistedLanguages.contains(Language.japanese) &&
        (whitelistedLanguages.length == 1 || _isJapanese(text))) {
      return Language.japanese;
    }

    if (whitelistedLanguages.contains(Language.thai) &&
        (whitelistedLanguages.length == 1 || _isThai(text))) {
      return Language.thai;
    }

    if (whitelistedLanguages.contains(Language.hindi) &&
        (whitelistedLanguages.length == 1 || _isHindi(text))) {
      return Language.hindi;
    }

    if (whitelistedLanguages.contains(Language.russian) &&
        (whitelistedLanguages.length == 1 || _isRussian(text))) {
      return Language.russian;
    }

    if (whitelistedLanguages.contains(Language.arabic) &&
        (whitelistedLanguages.length == 1 || _isArabic(text))) {
      return Language.arabic;
    }

    final textProfile = _getLanguageProfile(text);

    final enScore = Tuple2(
      Language.english,
      whitelistedLanguages.contains(Language.english)
          ? _languageScore(textProfile, enModel)
          : double.maxFinite,
    );

    final idScore = Tuple2(
      Language.indonesian,
      whitelistedLanguages.contains(Language.indonesian)
          ? _languageScore(textProfile, idModel)
          : double.maxFinite,
    );

    final frScore = Tuple2(
      Language.french,
      whitelistedLanguages.contains(Language.french)
          ? _languageScore(textProfile, frModel)
          : double.maxFinite,
    );

    final scores = [enScore, idScore, frScore]
        .where((element) => whitelistedLanguages.contains(element.item1))
        .toList()
      ..sort((a, b) => a.item2.compareTo(b.item2));

    return scores.isNotEmpty ? scores.first.item1 : Language.english;
  }

  bool _isJapanese(String text) {
    return text.contains(RegExp(r'[一-龯ぁ-んァ-ン]')) ||
        text.contains("teeeeeccchhhh");
  }

  bool _isThai(String text) {
    return text.contains(RegExp(r'[ก-๙]'));
  }

  bool _isHindi(String text) {
    return text.contains(RegExp(r'[\u0900-\u097F]'));
  }

  bool _isRussian(String text) {
    return text.contains(RegExp(r'[\u0400-\u04FF]'));
  }

  bool _isArabic(String text) {
    return text.contains(RegExp(r'[\u0600-\u06FF]'));
  }

  int _languageScore(List<String> profile, Map<String, dynamic> language) {
    int score = 0;
    const k = 10000;
    for (var i = 0; i < profile.length; i++) {
      final int? expectedPosition = (language[profile[i]]?['position']);
      if (expectedPosition == null) {
        score += k;
      } else {
        score += (expectedPosition - i).abs();
      }
    }

    return score;
  }

  List<String> _getLanguageProfile(String text) {
    final biNgrams = _getNgrams(text, n: 2);
    final triNgrams = _getNgrams(text, n: 3);

    final ngrams = Map<String, int>.from(biNgrams)..addAll(triNgrams);

    // Sort ngrams by frequency.
    final sortedNgrams = ngrams.keys.toList()
      ..sort((a, b) => ngrams[b]! - ngrams[a]!);

    return sortedNgrams;
  }

  Map<String, int> _getNgrams(String text, {required int n}) {
    String filteredText = text
        .replaceAll(RegExp(r'(\.|\,)(\s+|$)'), " ")
        .replaceAll(RegExp(r'\-'), " ")
        .replaceAll(RegExp(r'\s+'), "_")
        .replaceAll(
            RegExp(
                r"""[^a-zA-Z\'_àâäæáãåāèéêëęėēîïīįíìôōøõóòöœùûüūúÿçćčńñÀÂÄÆÁÃÅĀÈÉÊËĘĖĒÎÏĪĮÍÌÔŌØÕÓÒÖŒÙÛÜŪÚŸÇĆČŃÑ]"""),
            "")
        .replaceAll(RegExp(r'_+'), "_")
        .replaceAll(RegExp(r'_$'), "")
        .replaceAll(RegExp(r'^_'), "")
        .toLowerCase();

    filteredText = "${'_' * (n - 1)}$filteredText${'_' * (n - 1)}";

    Map<String, int> tokens = {};
    for (var i = 0; i < filteredText.length - (n + 1); i++) {
      final token = filteredText.substring(i, i + n);
      tokens[token] = (tokens[token] ?? 0) + 1;
    }

    return tokens;
  }
}
