extension YouTubeStringExtension on String {
  String? get youtubeVideoId {
    final String input = this;

    // Regular expression to validate a YouTube video ID
    final RegExp idRegExp = RegExp(r'^[a-zA-Z0-9_-]{11}$');

    // If input matches the video ID pattern, return it directly
    if (idRegExp.hasMatch(input)) {
      return input;
    }

    String url = input;

    // Add 'http://' if the scheme is missing
    if (!url.startsWith(RegExp(r'https?://'))) {
      url = 'http://$url';
    }

    // Try to parse the input as a URI
    Uri? uri = Uri.tryParse(url);

    if (uri != null) {
      // Handle youtube.com URLs
      if (uri.host.contains('youtube.com')) {
        // Check for 'v' parameter in query
        String? vId = uri.queryParameters['v'];
        if (vId != null && idRegExp.hasMatch(vId)) {
          return vId;
        }

        // Check for '/embed/VIDEO_ID' or '/v/VIDEO_ID'
        List<String> pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          int index = pathSegments.indexWhere((segment) =>
              segment == 'embed' || segment == 'v' || segment == 'e');
          if (index != -1 && pathSegments.length > index + 1) {
            String id = pathSegments[index + 1];
            if (idRegExp.hasMatch(id)) {
              return id;
            }
          }
        }
      }

      // Handle youtu.be URLs
      if (uri.host.contains('youtu.be')) {
        List<String> pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          String id = pathSegments[0];
          if (idRegExp.hasMatch(id)) {
            return id;
          }
        }
      }
    }

    // Fallback: extract ID using a regular expression
    final RegExp regex = RegExp(
      r'^(?:https?:\/\/)?' // Optional scheme
      r'(?:www\.)?' // Optional www
      r'(?:youtube\.com|youtu\.be)' // Domain
      r'(?:\/(?:[\w\-]+\?v=|embed\/|v\/))?' // Optional path prefixes
      r'([\w\-]{11})' // Video ID
      r'(?:\S+)?$', // Optional query parameters
      caseSensitive: false,
      multiLine: false,
    );

    Match? match = regex.firstMatch(input);
    if (match != null && match.groupCount >= 1) {
      String id = match.group(1)!;
      if (idRegExp.hasMatch(id)) {
        return id;
      }
    }

    // Return null if no video ID is found
    return null;
  }
}
