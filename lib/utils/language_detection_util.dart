import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:tuple/tuple.dart';

class LanguageDetection {
  static Map<String, dynamic> enModel = {};
  static Map<String, dynamic> idModel = {};

  LanguageDetection() {
    _loadLanguageModels();
  }

  void _loadLanguageModels() async {
    final String enJsonString =
        await rootBundle.loadString("assets/en_ngram_model.json");
    final String idJsonString =
        await rootBundle.loadString("assets/id_ngram_model.json");

    enModel = json.decode(enJsonString);
    idModel = json.decode(idJsonString);
  }

  Language getLanguage(
    String text, {
    required Set<Language> whitelistedLanguages,
  }) {
    if (whitelistedLanguages.contains(Language.japanese) &&
        (whitelistedLanguages.length == 1 || _isJapanese(text))) {
      return Language.japanese;
    }

    final textProfile = _getLanguageProfile(text);

    final enScore = Tuple2(
      Language.english,
      _languageScore(textProfile, enModel),
    );
    final idScore = Tuple2(
      Language.indonesian,
      _languageScore(textProfile, idModel),
    );

    final scores = [enScore, idScore]
        .where((element) => whitelistedLanguages.contains(element.item1))
        .toList()
      ..sort((a, b) => a.item2.compareTo(b.item2));

    return scores.isNotEmpty ? scores.first.item1 : Language.english;
  }

  bool _isJapanese(String text) {
    return text.contains(RegExp(r'[一-龯ぁ-んァ-ン]')) ||
        text.contains("teeeeeccchhhh");
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
    final filteredText = text
        .replaceAll(RegExp(r'(\.|\,)(\s+|$)'), " ")
        .replaceAll(RegExp(r'\-'), " ")
        .replaceAll(RegExp(r'\s+'), "_")
        .replaceAll(RegExp(r"""[^a-zA-Z\'_]"""), "")
        .replaceAll(RegExp(r'_+'), "_")
        .replaceAll(RegExp(r'_$'), "")
        .replaceAll(RegExp(r'^_'), "")
        .toLowerCase();

    Map<String, int> tokens = {};
    for (var i = 0; i < filteredText.length - (n + 1); i++) {
      final token = filteredText.substring(i, i + n);
      tokens[token] = (tokens[token] ?? 0) + 1;
    }

    return tokens;
  }
}
