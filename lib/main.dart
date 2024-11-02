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
import 'package:streamkit_tts/models/enums/tts_source.dart';
import 'package:streamkit_tts/screens/home/home.dart';
import 'package:streamkit_tts/services/composers/app_composer_service.dart';
import 'package:streamkit_tts/services/composers/composer_service.dart';
import 'package:streamkit_tts/services/language_detection_service.dart';
import 'package:streamkit_tts/services/middlewares/bsr_middleware.dart';
import 'package:streamkit_tts/services/middlewares/dev_commands_middleware.dart';
import 'package:streamkit_tts/services/middlewares/forced_language_middleware.dart';
import 'package:streamkit_tts/services/middlewares/language_middleware.dart';
import 'package:streamkit_tts/services/middlewares/message_cleanup_middleware.dart';
import 'package:streamkit_tts/services/middlewares/name_fix_middleware.dart';
import 'package:streamkit_tts/services/middlewares/pachify_middleware.dart';
import 'package:streamkit_tts/services/middlewares/read_username_middleware.dart';
import 'package:streamkit_tts/services/middlewares/remove_emotes_middleware.dart';
import 'package:streamkit_tts/services/middlewares/remove_urls_middleware.dart';
import 'package:streamkit_tts/services/middlewares/skip_empty_middleware.dart';
import 'package:streamkit_tts/services/middlewares/skip_exclamation_middleware.dart';
import 'package:streamkit_tts/services/middlewares/user_filter_middleware.dart';
import 'package:streamkit_tts/services/middlewares/word_fix_middleware.dart';
import 'package:streamkit_tts/services/outputs/google_tts_output.dart';
import 'package:streamkit_tts/services/sources/twitch_chat_source.dart';
import 'package:streamkit_tts/services/version_check_service.dart';
import 'package:streamkit_tts/utils/external_config_util.dart';
import 'package:streamkit_tts/utils/misc_tts_util.dart';
import 'package:version/version.dart';

Timer? _saveConfigTimer;
bool trakteerFeatureFlag = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final externalConfigUtil = ExternalConfig();
  await externalConfigUtil.loadConfigPath();

  final config = await loadConfigurations(
    configPath: externalConfigUtil.configPath,
    appPath: externalConfigUtil.appPath,
  );
  final LanguageDetectionService languageDetectionService =
      AppLanguageDetectionService();

  final versionCheckService = VersionCheckService();

  final ComposerService composerService = AppComposerService(
    config: config,
    sourceService: TwitchChatSource(config: config),
    middlewares: [
      // Filter and command handler middlewares
      DevCommandsMiddleware(
        externalConfig: externalConfigUtil,
        versionCheckService: versionCheckService,
      ),
      UserFilterMiddleware(config: config),
      BsrMiddleware(config: config),
      SkipExclamationMiddleware(config: config),

      // Message clean-up middlewares
      RemoveEmotesMiddleware(config: config),
      RemoveUrlsMiddleware(config: config),

      ForcedLanguageMiddleware(),
      PachifyMiddleware(
        externalConfig: externalConfigUtil,
        miscTtsUtil: MiscTts(),
      ),
      LanguageMiddleware(
        config: config,
        languageDetectionService: languageDetectionService,
      ),
      SkipEmptyMiddleware(config: config),
      ReadUsernameMiddleware(config: config),
      NameFixMiddleware(externalConfig: externalConfigUtil),
      WordFixMiddleware(externalConfig: externalConfigUtil),
      MessageCleanupMiddleware(config: config),
    ],
    outputService: GoogleTtsOutput(config: config),
  );

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
        ChangeNotifierProvider(create: (_) => versionCheckService),
        Provider(create: (_) => composerService),
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
  } catch (_) {}

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
      ttsSource: TtsSource.google,
      filteredUsernames: {},
      isWhitelistingFilter: false,
      ignoreEmptyMessage: true,
      ignoreUrls: true,
      disableAKeongFilter: false,
    ),
  );
}

class MyApp extends HookWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final paneIndex = useState(0);

    return FluentApp(
      title: "StreamKit Chat Reader",
      debugShowCheckedModeBanner: false,
      theme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: const Color.fromARGB(255, 100, 65, 165).toAccentColor(),
      ),
      home: NavigationView(
        appBar: Platform.isWindows ? streamKitAppBar(context) : null,
        pane: trakteerFeatureFlag
            ? NavigationPane(
                selected: paneIndex.value,
                onChanged: (value) {
                  paneIndex.value = value;
                },
                displayMode: PaneDisplayMode.compact,
                items: [
                  PaneItem(
                    icon: SvgPicture.asset("assets/images/twitch_icon.svg"),
                    title: const Text("Twitch"),
                    body: const Home(),
                  ),
                ],
              )
            : null,
        content: trakteerFeatureFlag ? null : const Home(),
      ),
    );
  }

  NavigationAppBar streamKitAppBar(BuildContext context) {
    return NavigationAppBar(
      actions: Row(
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
                  iconNormal: Colors.white, mouseOver: Colors.red)),
        ],
      ),
      automaticallyImplyLeading: false,
      height: 36.0,
      leading: const Padding(
        padding: EdgeInsets.only(bottom: 8.0, left: 12.0),
        child: Text(
          "🧈",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class StreamKitTitleBar extends HookWidget {
  const StreamKitTitleBar({super.key});

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
      titleBarText += " ${versionParsed.major}";
      if (versionParsed.minor != 0 || versionParsed.patch != 0) {
        titleBarText += ".${versionParsed.minor}";
      }
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
          margin: const EdgeInsets.only(left: 96),
          alignment: Alignment.center,
          child: Text(titleBarText),
        ),
      ),
    );
  }
}
