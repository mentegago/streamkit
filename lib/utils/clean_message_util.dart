extension CleanMessage on String {
  String replaceStrings(
    List<String> replaceList, {
    String replacement = "",
    bool wholeWord = false,
    bool caseInsensitive = false,
    bool isUsername = false,
  }) {
    String result = this;

    for (String toReplace in replaceList) {
      final pattern = _buildStringMatchPattern(
        toReplace,
        wholeWord: wholeWord,
        caseInsensitive: caseInsensitive,
        isUsername: isUsername,
      );

      if (wholeWord) {
        result = result.replaceAllMapped(pattern, (match) {
          final before = match.group(1) ?? '';
          final after = match.group(2) ?? '';
          return before + replacement + after;
        });
      } else {
        result = result.replaceAll(pattern, replacement);
      }
    }

    return result.trim();
  }

  bool containsString(
    String needle, {
    bool wholeWord = false,
    bool caseInsensitive = false,
  }) {
    return _buildStringMatchPattern(
      needle,
      wholeWord: wholeWord,
      caseInsensitive: caseInsensitive,
    ).hasMatch(this);
  }

  String removeUrls() {
    final urlPattern = RegExp(
      r'(https?:\/\/[^\s]+)|(www\.[^\s]+)',
      caseSensitive: false,
    );
    return replaceAll(urlPattern, '');
  }

  RegExp _buildStringMatchPattern(
    String word, {
    required bool wholeWord,
    required bool caseInsensitive,
    bool isUsername = false,
  }) {
    if (wholeWord) {
      final leadingPattern = isUsername ? r'(^|\s|@)' : r'(^|\s)';
      final patternString =
          leadingPattern + RegExp.escape(word) + r'(\s|[.,!?:;]|$)';
      return RegExp(patternString, caseSensitive: !caseInsensitive);
    } else {
      return RegExp(RegExp.escape(word), caseSensitive: !caseInsensitive);
    }
  }
}
