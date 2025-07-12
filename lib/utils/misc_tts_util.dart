class MiscTts {
  String pachify(
    String text, {
    required String userId,
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
    if (usernameList.contains(userId.toLowerCase()) ||
        usernameList.contains(
          userId, // Handle YouTube case where userId is case-sensitive
        )) {
      pachiReplacement = 'panci panci panci';
    }

    return text.replaceAll(RegExp(r'(8|８){3,}'), pachiReplacement);
  }

  String warafy(String text) {
    if (text == "w" || text == "ｗ") return "わら";
    return text
        .replaceAll(
          RegExp(r'(( |^|\n|\r)(w|ｗ){2,}( |$|\n|\r))'),
          'わらわら',
        )
        .replaceAllMapped(
          RegExp(r'([一-龯ぁ-んァ-ン？！?!])(w|ｗ)+( |$|\n|\r)'),
          (m) => "${m[1]}わら",
        );
  }
}
