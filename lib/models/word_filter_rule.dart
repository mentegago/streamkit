import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class WordFilterRule {
  final String id;
  final String word;
  final bool caseSensitive;
  final bool wholeWord;

  WordFilterRule({
    String? id,
    required this.word,
    this.caseSensitive = false,
    this.wholeWord = false,
  }) : id = id ?? _uuid.v4();

  WordFilterRule copyWith({
    String? id,
    String? word,
    bool? caseSensitive,
    bool? wholeWord,
  }) {
    return WordFilterRule(
      id: id ?? this.id,
      word: word ?? this.word,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      wholeWord: wholeWord ?? this.wholeWord,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'caseSensitive': caseSensitive,
      'wholeWord': wholeWord,
    };
  }

  factory WordFilterRule.fromMap(Map<String, dynamic> map) {
    return WordFilterRule(
      id: map['id'] as String?,
      word: map['word'] as String,
      caseSensitive: map['caseSensitive'] as bool? ?? false,
      wholeWord: map['wholeWord'] as bool? ?? false,
    );
  }
}
