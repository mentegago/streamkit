import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

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
  final String downloadUrl;
  final String? announcement;
  final String? announcementUrl;

  VersionStatus({
    required this.state,
    this.latestVersion = "0.0.0",
    required this.downloadUrl,
    this.announcement,
    this.announcementUrl,
  });
}

class VersionCheckService extends ChangeNotifier {
  final _apiUrl = "https://pastebin.com/raw/2VAGpvdE";
  final String _defaultDownloadUrl = "https://discord.nnt.gg";

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
      _updateState(VersionStatus(
        state: VersionState.loading,
        downloadUrl: _defaultDownloadUrl,
      ));

      final response = await http.get(
        Uri.parse(_apiUrl),
      );

      if (response.statusCode != 200) {
        _updateState(VersionStatus(
          state: VersionState.error,
          downloadUrl: _defaultDownloadUrl,
        ));
        return;
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      final String latestVersionString = json["latestVersion"];
      final String downloadUrl = json["downloadUrl"] ?? _defaultDownloadUrl;

      final packageInfo = await PackageInfo.fromPlatform();

      final currentVersion = Version.parse(packageInfo.version);
      final latestVersion = Version.parse(latestVersionString);

      if (latestVersion > currentVersion) {
        _updateState(
          VersionStatus(
            state: VersionState.outdated,
            latestVersion: latestVersionString,
            downloadUrl: downloadUrl,
            announcement: json["outOfDateAnnouncement"],
            announcementUrl: json["outOfDateAnnouncementUrl"],
          ),
          currentVersion: packageInfo.version,
        );
      } else if (latestVersion == currentVersion) {
        _updateState(
          VersionStatus(
            state: VersionState.upToDate,
            latestVersion: latestVersionString,
            downloadUrl: downloadUrl,
            announcement: json["currentAnnouncement"],
            announcementUrl: json["currentAnnouncementUrl"],
          ),
          currentVersion: packageInfo.version,
        );
      } else {
        _updateState(
          VersionStatus(
            state: VersionState.beta,
            latestVersion: latestVersionString,
            downloadUrl: downloadUrl,
            announcement: json["currentAnnouncement"],
            announcementUrl: json["currentAnnouncementUrl"],
          ),
          currentVersion: packageInfo.version,
        );
      }
    } catch (e) {
      _updateState(VersionStatus(
        state: VersionState.error,
        downloadUrl: _defaultDownloadUrl,
      ));
    }
  }
}
