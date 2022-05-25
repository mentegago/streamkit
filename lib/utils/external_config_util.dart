import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:streamkit_tts/models/name_fix_config_model.dart';
import 'package:path_provider/path_provider.dart';

class ExternalConfig {
  final String userAgent = 'MentegaStreamKit';

  final Set<String> _panciList = {};
  NameFixConfig _nameFixConfig = NameFixConfig(names: [], namesMap: {});

  Set<String> get panciList => _panciList;
  NameFixConfig get nameFixConfig => _nameFixConfig;
  String get appPath => _appPath;
  String get configPath => _configPath;

  final _appPath = Platform.resolvedExecutable.lastIndexOf('\\') != -1
      ? Platform.resolvedExecutable
          .substring(0, Platform.resolvedExecutable.lastIndexOf('\\'))
      : Platform.resolvedExecutable
          .substring(0, Platform.resolvedExecutable.lastIndexOf('/'));

  late final String _configPath;

  ExternalConfig() {
    loadPanciList();
    loadNameFixList();
  }

  Future<void> loadConfigPath() async {
    final appDataDir = await getApplicationDocumentsDirectory();
    final directory =
        Directory("${appDataDir.path}\\Mentega StreamKit\\Chat Reader");
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    _configPath = directory.path;
  }

  Future<void> loadPanciList() async {
    http.get(Uri.parse("https://pastebin.com/raw/NtEsN3nQ")).then((response) {
      if (response.statusCode != 200) return;
      _panciList.clear();
      response.body.split(',').forEach((element) {
        if (element.trim().isEmpty) return;
        _panciList.add(element);
      });
    });
  }

  Future<void> loadNameFixList() async {
    http.get(Uri.parse("https://pastebin.com/raw/vrrsngeG")).then((response) {
      if (response.statusCode != 200) return;
      _nameFixConfig = NameFixConfig.fromJson(json.decode(response.body));
    });
  }
}
