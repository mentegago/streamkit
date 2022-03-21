import 'dart:convert';

import 'package:streamkit/modules/enums/language.dart';

NameFixConfig nameFixConfigFromJson(String str) =>
    NameFixConfig.fromJson(json.decode(str));

String nameFixConfigToJson(NameFixConfig data) => json.encode(data.toJson());

class NameFixConfig {
  NameFixConfig({
    required this.names,
    required this.namesMap,
  });

  List<Name> names;
  Map<String, Name> namesMap;

  factory NameFixConfig.fromJson(Map<String, dynamic> json) {
    final names = List<Name>.from(json["names"].map((x) => Name.fromJson(x)));
    final Map<String, Name> namesMap =
        Map.fromIterable(names, key: (x) => x.original);

    return NameFixConfig(
      names: List<Name>.from(
        json["names"].map((x) => Name.fromJson(x)),
      ),
      namesMap: namesMap,
    );
  }

  String getName({required String originalName, required Language language}) {
    final name = namesMap[originalName];
    if (name == null) {
      return originalName;
    }

    switch (language) {
      case Language.english:
        return name.en;
      case Language.indonesian:
        return name.id;
      case Language.japanese:
        return name.jp;
    }
  }

  Map<String, dynamic> toJson() => {
        "names": List<dynamic>.from(names.map((x) => x.toJson())),
      };
}

class Name {
  Name({
    required this.original,
    required this.jp,
    required this.id,
    required this.en,
  });

  String original;
  String jp;
  String id;
  String en;

  factory Name.fromJson(Map<String, dynamic> json) => Name(
        original: json["original"],
        jp: json["jp"],
        id: json["id"],
        en: json["en"],
      );

  Map<String, dynamic> toJson() => {
        "original": original,
        "jp": jp,
        "id": id,
        "en": en,
      };
}
