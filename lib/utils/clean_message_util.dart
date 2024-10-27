extension CleanMessage on String {
  String replaceWords(
    List<String> replaceList, {
    String replacement = "",
    bool replaceEndOfSentenceWord = false,
  }) {
    String result = this;

    // Define punctuation characters to include
    String punctuation = r'.,!?:;';

    for (String toReplace in replaceList) {
      // Build the regular expression pattern based on the includePunctuation flag
      String patternString;
      if (replaceEndOfSentenceWord) {
        patternString = r'(^|\s)' +
            RegExp.escape(toReplace) +
            r'(\s|[' +
            punctuation +
            r']|$)';
      } else {
        patternString = r'(^|\s)' + RegExp.escape(toReplace) + r'(\s|$)';
      }
      final pattern = RegExp(patternString);

      result = result.replaceAllMapped(pattern, (match) {
        // Capture leading and trailing characters
        String before = match.group(1) ?? '';
        String after = match.group(2) ?? '';

        // If after is punctuation and we are replacing with an empty string, remove the punctuation
        if (replaceEndOfSentenceWord &&
            replacement.isEmpty &&
            RegExp('[$punctuation]').hasMatch(after)) {
          after = '';
        }

        return before + replacement + after;
      });
    }

    // Trim any extra spaces from the result
    return result.trim();
  }
}
