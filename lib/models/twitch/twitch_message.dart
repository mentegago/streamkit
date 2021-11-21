import 'package:streamkit/modules/chat_to_speech/models/user_state.dart';

class TwitchMessage {
  final String username;
  final String message;
  final String channel;
  final String emotelessMessage;
  final UserState userState;
  final bool self;

  TwitchMessage(this.message,
      {required this.username,
      required this.userState,
      required this.channel,
      required this.self,
      required this.emotelessMessage});
}
