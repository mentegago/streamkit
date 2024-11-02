import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/models/messages/chat_message.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';
import 'package:streamkit_tts/services/version_check_service.dart';
import 'package:streamkit_tts/utils/external_config_util.dart';

class DevCommandsMiddleware implements Middleware {
  final ExternalConfig _externalConfig;
  final VersionCheckService _versionCheckService;

  DevCommandsMiddleware({
    required externalConfig,
    required versionCheckService,
  })  : _externalConfig = externalConfig,
        _versionCheckService = versionCheckService;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;
    if (message.username.toLowerCase() != "mentegagoreng") return message;

    switch (message.rawMessage.trim()) {
      case "!updatenamefixlist":
        _externalConfig.loadNameFixList();
        break;

      case "!updatepancilist":
        _externalConfig.loadPanciList();
        break;

      case "!updatewordfixlist":
        _externalConfig.loadWordFixList();
        break;

      case "!!":
        return message.copyWith(
          suggestedSpeechMessage:
              "This user is running StreamKit ${_versionCheckService.currentVersion ?? "unknown version"}",
          isSuggestedSpeechMessageFinalized: true,
          language: Language.english,
        );
    }

    return message;
  }
}
