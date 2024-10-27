extension CleanMessage on String {
  String replaceWords(
    List<String> replaceList, {
    String replacement = "",
    bool replaceEndOfSentenceWord = false,
    bool caseInsensitive = false,
  }) {
    String result = this;

    // Define punctuation characters to include
    String punctuation = '.,!?:;';

    for (String toReplace in replaceList) {
      // Build the regular expression pattern using string interpolation
      String patternString;
      if (replaceEndOfSentenceWord) {
        patternString = r'(^|\s)' +
            RegExp.escape(toReplace) +
            r'(\s|[' +
            RegExp.escape(punctuation) +
            r']|$)';
      } else {
        patternString = r'(^|\s)' + RegExp.escape(toReplace) + r'(\s|$)';
      }

      // Build the regex with the appropriate options
      RegExp pattern = RegExp(
        patternString,
        caseSensitive: !caseInsensitive,
      );

      result = result.replaceAllMapped(pattern, (match) {
        // Capture leading and trailing characters
        String before = match.group(1) ?? '';
        String after = match.group(2) ?? '';

        // If after is punctuation and we are removing the word, remove the punctuation
        if (replaceEndOfSentenceWord &&
            replacement.isEmpty &&
            punctuation.contains(after.trim())) {
          after = '';
        }

        return before + replacement + after;
      });
    }

    // Trim any extra spaces from the result
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
