import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/server/twitch_user.dart';
import 'package:streamkit_tts/screens/home/widgets/dialogs/channel_selection_dialog.dart';
import 'package:streamkit_tts/services/server_service.dart';

class AccountBox extends HookWidget {
  const AccountBox({super.key});

  @override
  Widget build(BuildContext context) {
    final serverService = context.read<ServerService>();
    final channel = context.select(
      (Config config) => config.chatToSpeechConfiguration.channels.firstOrNull,
    );

    final userState = useState<TwitchUser?>(null);
    final isLoading = useState<bool>(false);

    useEffect(() {
      Future<void> fetchUser() async {
        userState.value = null;

        if (channel == null) return;

        isLoading.value = true;

        try {
          final user = await serverService.fetchTwitchUser(channel);
          if (channel.toLowerCase() == user.login.toLowerCase()) {
            userState.value = user;
          }
        } on UserNotFoundException catch (_) {
          print("User not found");
        } on ServerException catch (_) {
          print("Server error");
        } catch (e) {
          print(e);
        } finally {
          isLoading.value = false;
        }
      }

      fetchUser();

      return null;
    }, [channel]);

    return Row(
      children: [
        _ProfilePicture(
          isLoading: isLoading.value,
          userState: userState.value,
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userState.value?.displayName ??
                    channel ??
                    "No channel selected",
              ),
              channel != null
                  ? const Opacity(
                      opacity: 0.5,
                      child: Text("Twitch Account"),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const ChannelSelectionDialog(),
            );
          },
          style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              fixedSize: const Size.fromHeight(38)),
          child: Text(
            channel == null ? "Select Channel" : "Change Channel",
          ),
        ),
      ],
    );
  }
}

class _ProfilePicture extends StatelessWidget {
  final bool isLoading;
  final TwitchUser? userState;

  const _ProfilePicture({
    required this.isLoading,
    required this.userState,
  });

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = userState?.profileImageUrl;
    return isLoading
        ? const SizedBox(
            width: 42,
            height: 42,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          )
        : SizedBox(
            width: 42,
            height: 42,
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )
                : profileImageUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                          profileImageUrl,
                        ),
                      )
                    : SvgPicture.asset(
                        "assets/images/twitch_icon.svg",
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSurface,
                          BlendMode.srcIn,
                        ),
                      ),
          );
  }
}
