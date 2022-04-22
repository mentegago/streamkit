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

  VersionStatus({
    required this.state,
    this.latestVersion = "0.0.0",
  });
}

class VersionCheckService extends ChangeNotifier {
  final _apiUrl =
      "https://api.github.com/repos/mentegago/streamkit/releases/latest";
  String get downloadUrl =>
      "https://github.com/mentegago/streamkit/releases/latest";

  late VersionStatus _status;
  VersionStatus get status => _status;

  VersionCheckService() {
    _checkLatestVersion();
  }

  void _updateState(VersionStatus status) {
    _status = status;
    notifyListeners();
  }

  void _checkLatestVersion() async {
    _updateState(VersionStatus(state: VersionState.loading));

    final response = await http.get(
      Uri.parse(_apiUrl),
    );
    if (response.statusCode != 200) {
      _updateState(VersionStatus(state: VersionState.error));
      return;
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    final tagName = json['tag_name'] as String;
    final packageInfo = await PackageInfo.fromPlatform();

    final currentVersion = Version.parse(packageInfo.version);
    final latestVersion = Version.parse(tagName);

    if (latestVersion > currentVersion) {
      _updateState(VersionStatus(
        state: VersionState.outdated,
        latestVersion: tagName,
      ));
    } else if (latestVersion == currentVersion) {
      _updateState(VersionStatus(
        state: VersionState.upToDate,
        latestVersion: tagName,
      ));
    } else {
      _updateState(VersionStatus(
        state: VersionState.beta,
        latestVersion: tagName,
      ));
    }
  }
}
