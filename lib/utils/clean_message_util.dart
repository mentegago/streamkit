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
      if (wholeWord) {
        final leadingPattern = isUsername ? r'(^|\s|@)' : r'(^|\s)';
        final patternString =
            leadingPattern + RegExp.escape(toReplace) + r'(\s|[.,!?:;]|$)';

        final pattern = RegExp(patternString, caseSensitive: !caseInsensitive);

        result = result.replaceAllMapped(pattern, (match) {
          final before = match.group(1) ?? '';
          final after = match.group(2) ?? '';
          return before + replacement + after;
        });
      } else {
        final pattern = RegExp(
          RegExp.escape(toReplace),
          caseSensitive: !caseInsensitive,
        );
        result = result.replaceAll(pattern, replacement);
      }
    }

    return result.trim();
  }

  String removeUrls() {
    final urlPattern = RegExp(
      r'(https?:\/\/[^\s]+)|(www\.[^\s]+)',
      caseSensitive: false,
    );
    return replaceAll(urlPattern, '');
  }
}
