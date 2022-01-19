import 'package:streamkit/app_config.dart';

class StringUtil {
  static String pachify(String text, {String username = ""}) {
    final defaultUsernameList = [
      'ngeq',
      'amikarei',
      'bagusnl',
      'ozhy27',
      'kalamuspls',
      'seiki_ryuuichi',
      'cepp18_',
      'sodiumtaro',
      'mentegagoreng',
    ];

    final usernameList =
        AppConfig.panciList.isEmpty ? defaultUsernameList : AppConfig.panciList;

    String pachiReplacement = 'パチパチパチ';
    if (usernameList.contains(username.toLowerCase())) {
      pachiReplacement = 'panci panci panci';
    }

    return text.replaceAll(RegExp(r'(8|８){3,}'), pachiReplacement);
  }

  static String warafy(String text) {
    return text.replaceAll(
      RegExp(r'(( |^|\n|\r)(w|ｗ){2,}( |$|\n|\r))'),
      'わらわら',
    );
  }
}
