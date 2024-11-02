import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streamkit_tts/models/server/twitch_user.dart';

class ServerService {
  final String baseUrl;

  ServerService({required this.baseUrl});

  /// Fetches Twitch user information from the server.
  ///
  /// Throws [UserNotFoundException] if the user is not found (404).
  /// Throws [ServerException] for other server errors (500).
  /// Throws [Exception] for any other errors.
  Future<TwitchUser> fetchTwitchUser(String twitchUsername) async {
    final username = twitchUsername.trim();
    if (username.isEmpty) {
      throw Exception("Username is empty");
    }

    final url = Uri.parse('$baseUrl/twitch/user/$username');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return TwitchUser.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw UserNotFoundException('User $username not found');
      } else if (response.statusCode == 500) {
        throw ServerException('Internal Server Error');
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      rethrow;
    }
  }
}

class UserNotFoundException implements Exception {
  final String message;
  UserNotFoundException(this.message);

  @override
  String toString() => 'UserNotFoundException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}
