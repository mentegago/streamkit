import 'dart:convert';
import 'dart:io';

import 'package:streamkit/configurations/configurations.dart';

class AppConfig {
  static Configurations configurations = Configurations.defaultConfiguration();
  static String appPath = Platform.resolvedExecutable.lastIndexOf('\\') != -1
      ? Platform.resolvedExecutable
          .substring(0, Platform.resolvedExecutable.lastIndexOf('\\'))
      : Platform.resolvedExecutable
          .substring(0, Platform.resolvedExecutable.lastIndexOf('/'));

  static Future<void> loadConfigurations() async {
    final file = File('$appPath/streamkit_configurations.json');
    if (file.existsSync()) {
      configurations =
          Configurations.fromJson(json.decode(file.readAsStringSync()));
    }
  }

  static void saveConfigurations(Configurations configuration) async {
    final file = File('$appPath/streamkit_configurations.json');
    const encoder = JsonEncoder.withIndent('  ');

    file.writeAsStringSync(encoder.convert(configuration.toJson()));
  }
}
