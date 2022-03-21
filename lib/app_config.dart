import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:streamkit/configurations/configurations.dart';
import 'package:streamkit/models/app_config/name_fix_config.dart';

class AppConfig {
  static const String userAgent = 'MentegaStreamKit';
  static Configurations configurations = Configurations.defaultConfiguration();

  static Set<String> panciList = {};
  static NameFixConfig nameFixConfig = NameFixConfig(names: [], namesMap: {});

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

  static Future<void> loadPanciList() async {
    http.get(Uri.parse("https://pastebin.com/raw/NtEsN3nQ")).then((response) {
      if (response.statusCode != 200) return;
      panciList.clear();
      response.body.split(',').forEach((element) {
        if (element.trim().isEmpty) return;
        panciList.add(element);
      });
    });
  }

  static Future<void> loadNameFixList() async {
    http.get(Uri.parse("https://pastebin.com/raw/vrrsngeG")).then((response) {
      if (response.statusCode != 200) return;
      nameFixConfig = NameFixConfig.fromJson(json.decode(response.body));
    });
  }

  static void saveConfigurations(Configurations configuration) async {
    final file = File('$appPath/streamkit_configurations.json');
    const encoder = JsonEncoder.withIndent('  ');

    file.writeAsStringSync(encoder.convert(configuration.toJson()));
  }
}
