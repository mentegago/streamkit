import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/chat_to_speech_config_model.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/models/enums/tts_source.dart';
import 'package:streamkit_tts/models/enums/app_theme_mode.dart';
import 'package:streamkit_tts/screens/home/home.dart';
import 'package:streamkit_tts/screens/settings/beat_saber_settings.dart';
import 'package:streamkit_tts/screens/settings/settings.dart';
import 'package:streamkit_tts/screens/settings/user_filter_settings.dart';
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
import 'package:streamkit_tts/services/middlewares/vtuber_name_filter_middleware.dart';
import 'package:streamkit_tts/services/middlewares/word_fix_middleware.dart';
import 'package:streamkit_tts/services/outputs/google_tts_output.dart';
import 'package:streamkit_tts/services/sources/youtube_chat_source.dart';
import 'package:streamkit_tts/services/server_service.dart';
import 'package:streamkit_tts/services/version_check_service.dart';
import 'package:streamkit_tts/utils/external_config_util.dart';
import 'package:streamkit_tts/utils/misc_tts_util.dart';
import 'package:streamkit_tts/utils/theme_extensions.dart';

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

  final ComposerService composerService = AppComposerService(
    config: config,
    sourceService: YouTubeChatSource(config: config),
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
      VtuberNameFilterMiddleware(config: config),
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

  doWhenWindowReady(() {
    const initialSize = Size(800, 600);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

void saveConfigurations(Config config, {required String configPath}) {
  final file = File('$configPath\\config_youtube.json');
  file.writeAsStringSync(config.chatToSpeechConfiguration.toJson());
}

Future<Config> loadConfigurations(
    {required String configPath, required String appPath}) async {
  final file = File('$configPath\\config_youtube.json');

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
    final themeMode = context.select(
      (Config config) => config.chatToSpeechConfiguration.themeMode,
    );

    final baseTheme = ThemeData(
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFFDC2626),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFDC2626),
        onPrimaryContainer: Color(0xFFFFFFFF),
        primaryFixed: Color(0xFFF7D0D0),
        primaryFixedDim: Color(0xFFEEA1A1),
        onPrimaryFixed: Color(0xFF610F0F),
        onPrimaryFixedVariant: Color(0xFF711212),
        secondary: Color(0xFFF5F5F5),
        onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFFF5F5F5),
        onSecondaryContainer: Color(0xFF000000),
        secondaryFixed: Color(0xFFFBFBFB),
        secondaryFixedDim: Color(0xFFF1F1F1),
        onSecondaryFixed: Color(0xFF4A4A4A),
        onSecondaryFixedVariant: Color(0xFF6A6A6A),
        tertiary: Color(0xFFF5F5F5),
        onTertiary: Color(0xFF000000),
        tertiaryContainer: Color(0xFFF5F5F5),
        onTertiaryContainer: Color(0xFF000000),
        tertiaryFixed: Color(0xFFFBFBFB),
        tertiaryFixedDim: Color(0xFFF1F1F1),
        onTertiaryFixed: Color(0xFF4A4A4A),
        onTertiaryFixedVariant: Color(0xFF6A6A6A),
        error: Color(0xFFEF4444),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFE6E6),
        onErrorContainer: Color(0xFF000000),
        surface: Color(0xFFFCFCFC),
        onSurface: Color(0xFF111111),
        surfaceDim: Color(0xFFE0E0E0),
        surfaceBright: Color(0xFFFDFDFD),
        surfaceContainerLowest: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFFF8F8F8),
        surfaceContainer: Color(0xFFF3F3F3),
        surfaceContainerHigh: Color(0xFFEDEDED),
        surfaceContainerHighest: Color(0xFFE7E7E7),
        onSurfaceVariant: Color(0xFF393939),
        outline: Color(0xFF919191),
        outlineVariant: Color(0xFFD1D1D1),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFF2A2A2A),
        onInverseSurface: Color(0xFFF1F1F1),
        inversePrimary: Color(0xFFFFBFBF),
        surfaceTint: Color(0xFFDC2626),
      ),
      useMaterial3: true,
      extensions: const [
        CustomColors.light,
      ],
    );

    final darkTheme = ThemeData(
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFDC2626),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFDC2626),
        onPrimaryContainer: Color(0xFFFFFFFF),
        primaryFixed: Color(0xFFF7D0D0),
        primaryFixedDim: Color(0xFFEEA1A1),
        onPrimaryFixed: Color(0xFF610F0F),
        onPrimaryFixedVariant: Color(0xFF711212),
        secondary: Color(0xFF262626),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFF262626),
        onSecondaryContainer: Color(0xFFFFFFFF),
        secondaryFixed: Color(0xFFFBFBFB),
        secondaryFixedDim: Color(0xFFF1F1F1),
        onSecondaryFixed: Color(0xFF4A4A4A),
        onSecondaryFixedVariant: Color(0xFF6A6A6A),
        tertiary: Color(0xFF262626),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFF262626),
        onTertiaryContainer: Color(0xFFFFFFFF),
        tertiaryFixed: Color(0xFFFBFBFB),
        tertiaryFixedDim: Color(0xFFF1F1F1),
        onTertiaryFixed: Color(0xFF4A4A4A),
        onTertiaryFixedVariant: Color(0xFF6A6A6A),
        error: Color(0xFF7F1D1D),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFF410F0F),
        onErrorContainer: Color(0xFFFFFFFF),
        surface: Color.fromARGB(255, 24, 24, 24),
        onSurface: Color(0xFFF1F1F1),
        surfaceDim: Color(0xFF060606),
        surfaceBright: Color(0xFF2C2C2C),
        surfaceContainerLowest: Color.fromARGB(255, 37, 37, 37),
        surfaceContainerLow: Color.fromARGB(255, 31, 31, 31),
        surfaceContainer: Color(0xFF151515),
        surfaceContainerHigh: Color(0xFF1D1D1D),
        surfaceContainerHighest: Color(0xFF282828),
        onSurfaceVariant: Color(0xFFCACACA),
        outline: Color(0xFF777777),
        outlineVariant: Color(0xFF414141),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFFE8E8E8),
        onInverseSurface: Color(0xFF2A2A2A),
        inversePrimary: Color(0xFF621919),
        surfaceTint: Color(0xFFDC2626),
      ),
      useMaterial3: true,
      extensions: const [
        CustomColors.dark,
      ],
    );

    return WindowBorder(
      color: baseTheme.primaryColor,
      child: MaterialApp(
        title: 'StreamKit Chat Reader',
        theme: baseTheme.copyWith(
          textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme),
          iconTheme: baseTheme.iconTheme.copyWith(
            size: 24,
            color: baseTheme.colorScheme.onSurface,
          ),
        ),
        darkTheme: darkTheme.copyWith(
          textTheme: GoogleFonts.plusJakartaSansTextTheme(darkTheme.textTheme),
          iconTheme: darkTheme.iconTheme.copyWith(
            size: 24,
            color: darkTheme.colorScheme.onSurface,
          ),
        ),
        themeMode:
            themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/settings/beat_saber': (context) => const BeatSaberSettingsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/settings/user_filter': (context) =>
              const UserFilterSettingsScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
