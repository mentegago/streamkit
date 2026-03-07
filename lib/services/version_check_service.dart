import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:streamkit_tts/app_version.dart';
import 'package:streamkit_tts/flavor_config.dart';

enum VersionState {
  loading,
  error,
  outdated,
  upToDate,
  beta,
}

class VersionStatus {
  final VersionState state;
  final String latestVersion;
  final String? downloadUrl;
  final String? announcement;
  final String? announcementUrl;
  final String? md5;

  VersionStatus({
    required this.state,
    this.latestVersion = "0.0.0",
    this.downloadUrl,
    this.announcement,
    this.announcementUrl,
    this.md5,
  });
}

class VersionCheckService extends ChangeNotifier {
  final _apiUrl = FlavorConfig.isYouTube
      ? "https://mentegago.github.io/streamkit-config/app-yt.json"
      : "https://mentegago.github.io/streamkit-config/app-ttv.json";

  late VersionStatus _status;
  String? _currentVersion;

  VersionStatus get status => _status;
  String? get currentVersion => _currentVersion;

  VersionCheckService() {
    _checkLatestVersion();
  }

  void _updateState(VersionStatus status, {String? currentVersion}) {
    _status = status;
    _currentVersion = currentVersion;
    notifyListeners();
  }

  void _checkLatestVersion() async {
    // I really don't want version checking system to crash the app.
    try {
      _updateState(
        VersionStatus(
          state: VersionState.loading,
          downloadUrl: null,
        ),
        currentVersion: appDisplayVersion,
      );

      final response = await http.get(
        Uri.parse(_apiUrl),
      );

      if (response.statusCode != 200) {
        _updateState(
          VersionStatus(
            state: VersionState.error,
            downloadUrl: null,
          ),
          currentVersion: appDisplayVersion,
        );
        return;
      }

      final Map<String, dynamic> json = jsonDecode(response.body);

      final String? platformKey = Platform.isWindows ? "windows" : null;
      if (platformKey == null || !json.containsKey(platformKey)) {
        _updateState(
          VersionStatus(
            state: VersionState.error,
            downloadUrl: null,
          ),
          currentVersion: appDisplayVersion,
        );
        return;
      }

      final platform = json[platformKey] as Map<String, dynamic>;
      final int latestBuildNumber = platform["latestBuildNumber"] as int;
      final String latestVersionString = platform["latestVersion"] as String;
      final String? downloadUrl = platform["downloadUrl"] as String?;
      final String? md5 = platform["md5"] as String?;

      if (latestBuildNumber > appBuildNumber) {
        _updateState(
          VersionStatus(
            state: VersionState.outdated,
            latestVersion: latestVersionString,
            downloadUrl: downloadUrl,
            announcement: platform["outOfDateAnnouncement"] as String?,
            announcementUrl: platform["outOfDateAnnouncementUrl"] as String?,
            md5: md5,
          ),
          currentVersion: appDisplayVersion,
        );
      } else if (latestBuildNumber == appBuildNumber) {
        _updateState(
          VersionStatus(
            state: VersionState.upToDate,
            latestVersion: latestVersionString,
            downloadUrl: downloadUrl,
            announcement: platform["upToDateAnnouncement"] as String?,
            announcementUrl: platform["upToDateAnnouncementUrl"] as String?,
            md5: md5,
          ),
          currentVersion: appDisplayVersion,
        );
      } else {
        _updateState(
          VersionStatus(
            state: VersionState.beta,
            latestVersion: latestVersionString,
            downloadUrl: downloadUrl,
            announcement: platform["betaAnnouncement"] as String?,
            announcementUrl: platform["betaAnnouncementUrl"] as String?,
            md5: md5,
          ),
          currentVersion: appDisplayVersion,
        );
      }
    } catch (e) {
      debugPrint("Error checking latest version: $e");
      _updateState(
        VersionStatus(
          state: VersionState.error,
          downloadUrl: null,
        ),
        currentVersion: appDisplayVersion,
      );
    }
  }
}
