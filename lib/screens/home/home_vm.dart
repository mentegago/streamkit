import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:streamkit/modules/stream_kit_module.dart';
import 'package:streamkit/screens/stream_kit_view_model.dart';

import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';
import 'package:version/version.dart';

enum VersionState {
  loading,
  error,
  outdated,
  upToDate,
  beta,
}

class HomeViewModel extends StreamKitViewModel {
  final Stream<ModuleState> chatToSpeechState;
  final _isOutdated = BehaviorSubject<Tuple2<VersionState, String?>>();
  final _currentVersion = BehaviorSubject<String>();

  Stream<Tuple2<VersionState, String?>> get isOutdated => _isOutdated.stream;
  Stream<String> get currentVersion => _currentVersion.stream;

  // TODO: These configs deserves to be in a better place :(
  final apiUrl =
      "https://api.github.com/repos/mentegago/streamkit/releases/latest";
  final downloadUrl = "https://github.com/mentegago/streamkit/releases/latest";

  HomeViewModel({required this.chatToSpeechState}) {
    _checkLatestVersion();
  }

  void _checkLatestVersion() async {
    // TODO: Definitely need to move this functionality somewhere better in the future.
    _isOutdated
        .add(const Tuple2<VersionState, String?>(VersionState.loading, null));
    final response = await http.get(
      Uri.parse(apiUrl),
    );
    if (response.statusCode != 200) {
      _isOutdated
          .add(const Tuple2<VersionState, String?>(VersionState.error, null));
      return;
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    final tagName = json['tag_name'] as String;
    final packageInfo = await PackageInfo.fromPlatform();

    final currentVersion = Version.parse(packageInfo.version);
    final latestVersion = Version.parse(tagName);

    if (latestVersion > currentVersion) {
      _isOutdated
          .add(Tuple2<VersionState, String?>(VersionState.outdated, tagName));
    } else if (latestVersion == currentVersion) {
      _isOutdated
          .add(Tuple2<VersionState, String?>(VersionState.upToDate, tagName));
    } else {
      _isOutdated
          .add(Tuple2<VersionState, String?>(VersionState.beta, tagName));
    }

    _currentVersion.add(currentVersion.toString());
  }
}
