import 'dart:convert';

import 'package:http/http.dart' as http;

class BeatSaverUtil {
  Future<String> getSongName({required String bsrCode}) async {
    final url = Uri.parse(
        "https://api.beatsaver.com/maps/id/${Uri.encodeFull(bsrCode)}");
    try {
      final response = await http.get(
        url,
        headers: {
          "User-Agent": "MentegaStreamKit",
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['metadata'] != null) {
          final metadata = json['metadata'];
          return metadata['songAuthorName'] +
              ' - ' +
              metadata['songName'] +
              ' ' +
              metadata['songSubName'];
        } else {
          return Future.error('Failed to load song name');
        }
      } else {
        return Future.error('Failed to load song name');
      }
    } catch (e) {
      return Future.error('Failed to load song name');
    }
  }
}
