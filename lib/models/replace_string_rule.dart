class ReplaceStringRule {
  final String from;
  final String to;
  final bool caseSensitive;
  final bool wholeWord;

  const ReplaceStringRule({
    required this.from,
    required this.to,
    this.caseSensitive = false,
    this.wholeWord = false,
  });

  ReplaceStringRule copyWith({
    String? from,
    String? to,
    bool? caseSensitive,
    bool? wholeWord,
  }) {
    return ReplaceStringRule(
      from: from ?? this.from,
      to: to ?? this.to,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      wholeWord: wholeWord ?? this.wholeWord,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'caseSensitive': caseSensitive,
      'wholeWord': wholeWord,
    };
  }

  factory ReplaceStringRule.fromMap(Map<String, dynamic> map) {
    return ReplaceStringRule(
      from: map['from'] as String,
      to: map['to'] as String,
      caseSensitive: map['caseSensitive'] as bool? ?? false,
      wholeWord: map['wholeWord'] as bool? ?? false,
    );
  }
}
