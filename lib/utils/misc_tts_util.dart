class MiscTts {
  String pachify(
    String text, {
    required String username,
    required Set<String> panciList,
  }) {
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

    final usernameList = panciList.isEmpty ? defaultUsernameList : panciList;

    String pachiReplacement = 'パチパチパチ';
    if (usernameList.contains(username.toLowerCase())) {
      pachiReplacement = 'panci panci panci';
    }

    return text.replaceAll(RegExp(r'(8|８){3,}'), pachiReplacement);
  }

  String warafy(String text) {
    return text.replaceAll(
      RegExp(r'(( |^|\n|\r)(w|ｗ){2,}( |$|\n|\r))'),
      'わらわら',
    );
  }
}
