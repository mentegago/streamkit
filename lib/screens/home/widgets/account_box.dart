import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/server/twitch_user.dart';
import 'package:streamkit_tts/services/server_service.dart';

class AccountBox extends HookWidget {
  const AccountBox({super.key});

  @override
  Widget build(BuildContext context) {
    final serverService = context.read<ServerService>();
    final channel = context.select(
      (Config config) =>
          config.chatToSpeechConfiguration.channels.firstOrNull ?? "",
    );

    final userState = useState<TwitchUser?>(null);
    final isLoading = useState<bool>(false);

    useEffect(() {
      Future<void> fetchUser() async {
        userState.value = null;

        if (channel.isEmpty) return;

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
              Text(userState.value?.displayName ?? channel),
              const Opacity(
                opacity: 0.5,
                child: Text("Twitch Account"),
              ),
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
              builder: (context) => const _ChannelSelectionDialog(),
            );
          },
          style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              fixedSize: const Size.fromHeight(38)),
          child: const Text("Change Channel"),
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
                    : SvgPicture.asset("assets/images/twitch_icon.svg"),
          );
  }
}

class _ChannelSelectionDialog extends HookWidget {
  const _ChannelSelectionDialog();

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController(
      text: context
              .read<Config>()
              .chatToSpeechConfiguration
              .channels
              .firstOrNull ??
          "",
    );

    final errorMessage = useState("");
    final focusNode = useFocusNode();

    focus() {
      focusNode.requestFocus();
      textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textController.text.length,
      );
    }

    onSubmitted() {
      if (textController.text.isEmpty) {
        errorMessage.value = "Enter a valid channel name";
        focus();
        return;
      }

      context.read<Config>().setChannelUsernames({
        textController.text,
      });

      Navigator.of(context).pop();
    }

    useEffect(() {
      focus();
      return null;
    }, []);

    return AlertDialog(
      title: const Text("Change Channel"),
      content: TextField(
        onSubmitted: (_) {
          onSubmitted();
        },
        decoration: InputDecoration(
          error:
              errorMessage.value.isNotEmpty ? Text(errorMessage.value) : null,
          labelText: "Twitch channel name",
        ),
        controller: textController,
        focusNode: focusNode,
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: onSubmitted,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
