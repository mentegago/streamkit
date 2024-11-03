import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/chat_to_speech_config_model.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/screens/home/home.dart';
import 'package:streamkit_tts/screens/settings/beat_saber_settings.dart';
import 'package:streamkit_tts/screens/settings/settings.dart';
import 'package:streamkit_tts/services/app_audio_handler_service.dart';
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
import 'package:streamkit_tts/services/server_service.dart';
import 'package:streamkit_tts/services/sources/twitch_chat_source.dart';
import 'package:streamkit_tts/services/version_check_service.dart';
import 'package:streamkit_tts/utils/external_config_util.dart';
import 'package:streamkit_tts/utils/misc_tts_util.dart';

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

  final serverService = ServerService(baseUrl: "https://streamkit-api.nnt.gg");

  final audioHandler = await AudioService.init(
    builder: () => AppAudioHandlerService(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mentegagoreng.streamkit.channel',
      androidNotificationChannelName: 'StreamKit Chat Reader',
      androidStopForegroundOnPause: false,
      androidNotificationOngoing: false,
    ),
  );

  final ComposerService composerService = AppComposerService(
    config: config,
    audioHandler: audioHandler,
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
        Provider(create: (_) => serverService),
      ],
      child: const MyApp(),
    ),
  );

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    doWhenWindowReady(() {
      const initialSize = Size(800, 600);
      appWindow.minSize = initialSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
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

  return Config(
    chatToSpeechConfiguration: ChatToSpeechConfiguration.defaultConfig(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 170, 42, 255),
        brightness: Brightness.light,
        surfaceContainerHighest: Colors.white,
        surfaceContainerLow: Colors.white,
      ),
      useMaterial3: true,
    );

    final darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 170, 42, 255),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

    return WindowBorder(
      color: baseTheme.primaryColor,
      child: MaterialApp(
        title: 'StreamKit Chat Reader',
        theme: baseTheme.copyWith(
          textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme),
        ),
        darkTheme: darkTheme.copyWith(
          textTheme: GoogleFonts.plusJakartaSansTextTheme(darkTheme.textTheme),
        ),
        themeMode: ThemeMode.dark,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/settings/beat_saber': (context) => const BeatSaberSettingsScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
