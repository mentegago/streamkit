import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/chat_to_speech_config_model.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/screens/home/home.dart';
import 'package:streamkit_tts/screens/trakteer/trakteer.dart';
import 'package:streamkit_tts/services/chat_to_speech_service.dart';
import 'package:streamkit_tts/services/version_check_service.dart';
import 'package:streamkit_tts/utils/beat_saver_util.dart';
import 'package:streamkit_tts/utils/external_config_util.dart';
import 'package:streamkit_tts/utils/language_detection_util.dart';
import 'package:streamkit_tts/utils/misc_tts_util.dart';
import 'package:version/version.dart';

Timer? _saveConfigTimer;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final externalConfigUtil = ExternalConfig();
  await externalConfigUtil.loadConfigPath();

  final config = await loadConfigurations(
    configPath: externalConfigUtil.configPath,
    appPath: externalConfigUtil.appPath,
  );
  final chatToSpeechService = ChatToSpeechService(
    config: config,
    languageDetectionUtil: LanguageDetection(),
    externalConfigUtil: externalConfigUtil,
    miscTtsUtil: MiscTts(),
    beatSaverUtil: BeatSaverUtil(),
  );
  final versionCheckService = VersionCheckService();

  config.addListener(() {
    _saveConfigTimer?.cancel();

    // Debounce for one seconds before saving configuration.
    _saveConfigTimer = Timer(
      const Duration(seconds: 1),
      () =>
          saveConfigurations(config, configPath: externalConfigUtil.configPath),
    );
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

void saveConfigurations(Config config, {required String configPath}) {
  final file = File('$configPath\\config.json');
  file.writeAsStringSync(config.chatToSpeechConfiguration.toJson());
}

Future<Config> loadConfigurations(
    {required String configPath, required String appPath}) async {
  final file = File('$configPath\\config.json');

  if (file.existsSync()) {
    final config = ChatToSpeechConfiguration.fromJson(file.readAsStringSync());
    return Config(chatToSpeechConfiguration: config);
  }

  try {
    final oldConfigFile = File('$appPath\\streamkit_configurations.json');
    if (oldConfigFile.existsSync()) {
      final config = ChatToSpeechConfiguration.fromOldJson(
          oldConfigFile.readAsStringSync());
      saveConfigurations(Config(chatToSpeechConfiguration: config),
          configPath: configPath);

      oldConfigFile.deleteSync();

      return Config(chatToSpeechConfiguration: config);
    }
  } catch (e) {}

  return Config(
    chatToSpeechConfiguration: ChatToSpeechConfiguration(
      channels: {},
      enabled: false,
      ignoreExclamationMark: true,
      languages: {Language.english, Language.indonesian, Language.japanese},
      readBsr: false,
      readUsername: true,
      volume: 100.0,
      ignoreEmotes: true,
      readBsrSafely: false,
    ),
  );
}

class MyApp extends HookWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final paneIndex = useState(0);

    return FluentApp(
      title: "StreamKit Chat Reader",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: const Color.fromARGB(255, 100, 65, 165).toAccentColor(),
      ),
      home: NavigationView(
        appBar: streamKitAppBar(context),
        pane: NavigationPane(
          selected: paneIndex.value,
          onChanged: (value) {
            paneIndex.value = value;
          },
          displayMode: PaneDisplayMode.compact,
          items: [
            PaneItem(
              icon: SvgPicture.asset("assets/images/twitch_icon.svg"),
              title: const Text("Twitch"),
            ),
            PaneItem(
              icon: Image.asset('assets/images/trakteer_icon.png'),
              title: const Text("Trakteer"),
            ),
          ],
        ),
        content: NavigationBody(
          index: paneIndex.value,
          children: const [
            Home(),
            Trakteer(),
          ],
        ),
      ),
    );
  }

  NavigationAppBar streamKitAppBar(BuildContext context) {
    return NavigationAppBar(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: MoveWindow(
              child: const StreamKitTitleBar(),
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
        padding: EdgeInsets.only(bottom: 4.0),
        child: Text("🧈", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class StreamKitTitleBar extends HookWidget {
  const StreamKitTitleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visible = useState(false);
    final versionCheckService = context.watch<VersionCheckService>();

    final version = versionCheckService.currentVersion;
    final versionInfo = versionCheckService.status.state == VersionState.beta
        ? "prerelease"
        : versionCheckService.status.state == VersionState.outdated
            ? "outdated"
            : "";

    String titleBarText = "StreamKit";

    if (version != null) {
      final versionParsed = Version.parse(version);
      titleBarText += " ${versionParsed.major}.${versionParsed.minor}";
      if (versionParsed.patch != 0) {
        titleBarText += ".${versionParsed.patch}";
      }
    }

    if (versionInfo.isNotEmpty) {
      titleBarText += " ($versionInfo)";
    }

    return MouseRegion(
      onEnter: (event) {
        visible.value = true;
      },
      onExit: (event) {
        visible.value = false;
      },
      child: AnimatedOpacity(
        opacity: visible.value ? 0.5 : 0.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          child: Text(titleBarText),
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
