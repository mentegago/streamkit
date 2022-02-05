import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:streamkit/app_config.dart';

class BeatSaverUtil {
  static Future<String> getSongName({required String bsrCode}) async {
    final url = Uri.parse(
        "https://api.beatsaver.com/maps/id/${Uri.encodeFull(bsrCode)}");
    final response = await http.get(
      url,
      headers: {
        'User-Agent': AppConfig.userAgent,
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
  }
}
