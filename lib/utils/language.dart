import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:streamkit/modules/enums/language.dart';

class LanguageUtil {
  static final JavascriptRuntime _runtime = () {
    final runtime = getJavascriptRuntime();

    // Load Franc
    rootBundle.loadString('assets/franc-min.js').then((script) {
      runtime.evaluate(script);
    });

    return runtime;
  }();

  // Get language from Franc JavaScript library.
  static Language getLanguage(
      {required String text,
      Set<Language> whitelistedLanguages = const {
        Language.indonesian,
        Language.english,
        Language.japanese
      }}) {
    if (text.contains("panci panci panci") &&
        whitelistedLanguages.contains(Language.indonesian)) {
      return Language.indonesian;
    }

    String francText = text;

    while (francText.length < 30 && francText.isNotEmpty) {
      francText += " " + text;
    }

    String languages =
        whitelistedLanguages.map((lang) => "'" + lang.franc + "'").join(", ");

    if (whitelistedLanguages.contains(Language.japanese)) {
      languages = languages +
          ", 'cmn'"; // Use Mandarin to guide Franc into recognizing Japanese kanji. I'm so so sorry, but I guess no Mandarin support anytime soon...
    }

    final textLanguage = _runtime
        .evaluate("franc('" +
            francText.replaceAll('\'', '\\\'') +
            "', { whitelist: [$languages] })")
        .stringResult;

    return LanguageParser.fromFranc(textLanguage) ??
        (whitelistedLanguages.isNotEmpty
            ? whitelistedLanguages.first
            : Language.indonesian);
  }
}
