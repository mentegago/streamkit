import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class ReplaceStringRule {
  final String id;
  final String from;
  final String to;
  final bool caseSensitive;
  final bool wholeWord;

  ReplaceStringRule({
    String? id,
    required this.from,
    required this.to,
    this.caseSensitive = false,
    this.wholeWord = false,
  }) : id = id ?? _uuid.v4();

  ReplaceStringRule copyWith({
    String? id,
    String? from,
    String? to,
    bool? caseSensitive,
    bool? wholeWord,
  }) {
    return ReplaceStringRule(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      wholeWord: wholeWord ?? this.wholeWord,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'caseSensitive': caseSensitive,
      'wholeWord': wholeWord,
    };
  }

  factory ReplaceStringRule.fromMap(Map<String, dynamic> map) {
    return ReplaceStringRule(
      id: map['id'] as String?,
      from: map['from'] as String,
      to: map['to'] as String,
      caseSensitive: map['caseSensitive'] as bool? ?? false,
      wholeWord: map['wholeWord'] as bool? ?? false,
    );
  }
}
