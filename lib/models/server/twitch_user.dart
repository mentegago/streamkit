class TwitchUser {
  final String id;
  final String login;
  final String displayName;
  final String type;
  final String broadcasterType;
  final String description;
  final String profileImageUrl;
  final String offlineImageUrl;

  TwitchUser({
    required this.id,
    required this.login,
    required this.displayName,
    required this.type,
    required this.broadcasterType,
    required this.description,
    required this.profileImageUrl,
    required this.offlineImageUrl,
  });

  factory TwitchUser.fromJson(Map<String, dynamic> json) {
    return TwitchUser(
      id: json['id'] as String,
      login: json['login'] as String,
      displayName: json['display_name'] as String,
      type: json['type'] as String,
      broadcasterType: json['broadcaster_type'] as String,
      description: json['description'] as String,
      profileImageUrl: json['profile_image_url'] as String,
      offlineImageUrl: json['offline_image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'display_name': displayName,
      'type': type,
      'broadcaster_type': broadcasterType,
      'description': description,
      'profile_image_url': profileImageUrl,
      'offline_image_url': offlineImageUrl,
    };
  }
}
