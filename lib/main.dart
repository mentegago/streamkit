import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/chat_to_speech_config_model.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/screens/home/home.dart';
import 'package:streamkit_tts/services/chat_to_speech_service.dart';
import 'package:streamkit_tts/services/version_check_service.dart';
import 'package:streamkit_tts/utils/external_config_util.dart';
import 'package:streamkit_tts/utils/language_detection_util.dart';
import 'package:streamkit_tts/utils/misc_tts_util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:version/version.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final externalConfigUtil = ExternalConfig();

  final config = await loadConfigurations(appPath: externalConfigUtil.appPath);
  final chatToSpeechService = ChatToSpeechService(
    config: config,
    languageDetectionUtil: LanguageDetection(),
    externalConfigUtil: externalConfigUtil,
    miscTtsUtil: MiscTts(),
  );
  final versionCheckService = VersionCheckService();

  config.addListener(() {
    final file = File('${externalConfigUtil.appPath}/config.json');
    file.writeAsStringSync(config.chatToSpeechConfiguration.toJson());
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => config),
        ChangeNotifierProvider(create: (_) => chatToSpeechService),
        ChangeNotifierProvider(create: (_) => versionCheckService),
      ],
      child: const MyApp(),
    ),
  );

  doWhenWindowReady(() {
    const initialSize = Size(800, 550);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

Future<Config> loadConfigurations({required String appPath}) async {
  final file = File('$appPath/config.json');

  if (file.existsSync()) {
    final config = ChatToSpeechConfiguration.fromJson(file.readAsStringSync());
    return Config(chatToSpeechConfiguration: config);
  }

  return Config(
    chatToSpeechConfiguration: ChatToSpeechConfiguration(
      channels: {},
      enabled: false,
      ignoreExclamationMark: true,
      languages: Language.values.toSet(),
      readBsr: true,
      readUsername: true,
      volume: 100.0,
      ignoreEmotes: true,
    ),
  );
}

class MyApp extends HookWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: "StreamKit Chat Reader",
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: const Color.fromARGB(255, 100, 65, 165).toAccentColor(),
      ),
      home: NavigationView(
        appBar: streamKitAppBar(),
        content: NavigationBody(
          index: 0,
          children: const [Home()],
        ),
      ),
    );
  }

  NavigationAppBar streamKitAppBar() {
    return NavigationAppBar(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: MoveWindow(
              child: Container(),
            ),
          ),
          MinimizeWindowButton(
              colors: WindowButtonColors(iconNormal: Colors.white)),
          MaximizeWindowButton(
              colors: WindowButtonColors(iconNormal: Colors.white)),
          CloseWindowButton(
              colors: WindowButtonColors(
                  iconNormal: Colors.white, mouseOver: Colors.red))
        ],
      ),
      automaticallyImplyLeading: false,
      height: 36.0,
      leading: const Padding(
        child: Text("🧈", style: TextStyle(fontSize: 24)),
        padding: EdgeInsets.only(bottom: 4.0),
      ),
    );
  }
}
