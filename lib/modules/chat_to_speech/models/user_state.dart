class UserBadge {
  final String name;
  final int version;

  UserBadge({required this.name, required this.version});

  factory UserBadge.fromValue(String badge) {
    final components = badge.split('/');
    return UserBadge(
        name: components.first, version: int.parse(components.last));
  }
}

class UserStateEmote {
  final String id;
  final int startIndex;
  final int endIndex;

  UserStateEmote(
      {required this.id, required this.startIndex, required this.endIndex});

  factory UserStateEmote.fromValue(String emote) {
    final components = emote.split(':');
    final id = components.first;

    final index = components.last.split('-');
    final startIndex = int.parse(index.first);
    final endIndex = int.parse(index.last);

    return UserStateEmote(id: id, startIndex: startIndex, endIndex: endIndex);
  }
}

class UserState {
  final UserBadge? badgeInfo;
  final List<UserBadge> badges;
  final String displayName;
  final bool mod;
  final bool subscriber;
  final bool broadcaster;
  final String userId;
  final List<UserStateEmote> emotes;

  UserState({
    required this.badgeInfo,
    required this.badges,
    required this.displayName,
    required this.mod,
    required this.subscriber,
    required this.broadcaster,
    required this.userId,
    required this.emotes,
  });

  factory UserState.fromString(String tags) {
    final tagRegex = RegExp("((?<key>[A-Za-z\\-]*)=(?<value>[^;]*))");
    final tagMatches = tagRegex.allMatches(tags).where((element) =>
        element.namedGroup("key") != null); // Make sure it has key.

    final userstate = {
      for (var match in tagMatches)
        match.namedGroup("key") ?? "": match.namedGroup("value")
    };

    return UserState.fromMap(userstate);
  }

  factory UserState.fromMap(Map<String, String?> map) {
    final badges = (map['badges'] ?? "")
        .split(',')
        .where((element) => element.isNotEmpty)
        .map((badge) => UserBadge.fromValue(badge))
        .toList();

    final badgeInfoString = map['badge-info'] ?? "";

    return UserState(
      badgeInfo: badgeInfoString.isNotEmpty
          ? UserBadge.fromValue(badgeInfoString)
          : null,
      badges: badges,
      displayName: map['display-name'] ?? "",
      mod: map['mod'] == '1',
      subscriber: map['subscriber'] == '1',
      broadcaster:
          badges.indexWhere((element) => element.name == 'broadcaster') != -1,
      userId: map['user-id'] ?? "",
      emotes: (map['emotes'] ?? "")
          .split('/')
          .where((element) => element.isNotEmpty)
          .map((emote) => UserStateEmote.fromValue(emote))
          .toList(),
    );
  }
}
