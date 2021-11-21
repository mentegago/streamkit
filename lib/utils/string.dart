class StringUtil {
  static String pachify(String text, {String username = ""}) {
    final usernameList = [
      'ngeq',
      'amikarei',
      'bagusnl',
      'ozhy27',
      'kalamuspls',
      'seiki_ryuuichi',
      'cepp18_',
      'mentegagoreng',
      'sodiumtaro'
    ];

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
