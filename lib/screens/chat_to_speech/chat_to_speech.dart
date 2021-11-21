import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flag/flag.dart';

import 'chat_to_speech_vm.dart';
import '../../modules/chat_to_speech/enums/language.dart';

class ChatToSpeech extends StatefulWidget {
  final ChatToSpeechViewModel viewModel;

  const ChatToSpeech({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<ChatToSpeech> createState() => _ChatToSpeechState();
}

class _ChatToSpeechState extends State<ChatToSpeech> {
  StreamSubscription<String>? _errorSubscription;

  @override
  void dispose() {
    _errorSubscription?.cancel();
    widget.viewModel.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _errorSubscription = widget.viewModel.error.listen((error) {
      showDialog(
          context: context,
          builder: (context) => ContentDialog(
                title: const Text("Oops..."),
                content: Text(error),
                actions: [
                  Button(
                      child: const Text("Ok"),
                      onPressed: () => Navigator.of(context).pop())
                ],
              ));
    });

    return ScaffoldPage(
        header: const PageHeader(title: Text("Twitch Chat Reader")),
        content: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextBox(
                inputFormatters: [ChannelTextFormatter()],
                header: "Channel name",
                controller: widget.viewModel.channelController,
                placeholder: "The channel where you want the chat to be read.",
              ),
              const SizedBox(height: 24),
              Wrap(
                direction: Axis.horizontal,
                spacing: 32,
                children: [
                  InfoLabel(
                    label: "Configurations",
                    child: Wrap(
                      direction: Axis.vertical,
                      spacing: 8,
                      children: [
                        StreamBuilder<bool>(
                            initialData: false,
                            stream: widget.viewModel.readUsername,
                            builder: (context, snapshot) {
                              return Checkbox(
                                  checked: snapshot.data,
                                  onChanged: (bool? value) {
                                    widget.viewModel
                                        .updateUsername(value ?? false);
                                  },
                                  content: const Text("Read username"));
                            }),
                        StreamBuilder<bool>(
                            initialData: false,
                            stream: widget.viewModel.ignoreExclamationMark,
                            builder: (context, snapshot) {
                              return Checkbox(
                                checked: snapshot.data,
                                onChanged: (bool? value) {
                                  widget.viewModel.updateIgnoreExclamationMark(
                                      value ?? false);
                                },
                                content: const Text(
                                    "Ignore messages starting with \"!\""),
                              );
                            })
                      ],
                    ),
                  ),
                  InfoLabel(
                    label: "Languages",
                    child: Wrap(
                      direction: Axis.vertical,
                      spacing: 8,
                      children: [
                        LanguageCheckbox(
                            language: Language.indonesian,
                            viewModel: widget.viewModel),
                        LanguageCheckbox(
                            language: Language.english,
                            viewModel: widget.viewModel),
                        LanguageCheckbox(
                            language: Language.japanese,
                            viewModel: widget.viewModel),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              StreamBuilder<ChatToSpeechConnectionState>(
                  stream: widget.viewModel.state,
                  initialData: ChatToSpeechConnectionState.idle,
                  builder: (context, snapshot) {
                    if (snapshot.data == ChatToSpeechConnectionState.loading) {
                      return const Center(child: ProgressRing());
                    } else {
                      List<Widget> buttons = [
                        Expanded(
                          child: Button(
                            child: Text(snapshot.data ==
                                    ChatToSpeechConnectionState.idle
                                ? "Connect"
                                : "Update configuration"),
                            onPressed: () {
                              if (widget
                                  .viewModel.channelController.text.isEmpty) {
                                showDialog(
                                    context: context,
                                    builder: (context) => ContentDialog(
                                          title: const Text("Oops..."),
                                          content: const Text(
                                              "Please enter a channel name!"),
                                          actions: [
                                            Button(
                                                child: const Text("Ok"),
                                                onPressed: () =>
                                                    Navigator.pop(context))
                                          ],
                                        ));
                                return;
                              }
                              widget.viewModel.setEnabled(true);
                            },
                          ),
                        )
                      ];

                      if (snapshot.data ==
                          ChatToSpeechConnectionState.connected) {
                        buttons.add(const SizedBox(width: 8));
                        buttons.add(Tooltip(
                          message: "Disconnect from channel",
                          child: IconButton(
                            icon: const Icon(FluentIcons.plug_disconnected),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => ContentDialog(
                                        title: const Text(
                                            'Disconnect from channel?'),
                                        content: const Text(
                                            'Are you sure you want to disconnect from the channel?'),
                                        actions: [
                                          Button(
                                              child:
                                                  const Text('Yes, disconnect'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                widget.viewModel
                                                    .setEnabled(false);
                                              }),
                                          Button(
                                              child: const Text('No'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              }),
                                        ],
                                      ));
                            },
                          ),
                        ));
                      }
                      return Row(
                        children: buttons,
                      );
                    }
                  }),
            ],
          ),
        ));
  }
}

class LanguageCheckbox extends StatelessWidget {
  final Language language;
  final ChatToSpeechViewModel viewModel;
  const LanguageCheckbox({
    Key? key,
    required this.language,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        initialData: false,
        stream: viewModel.language(language),
        builder: (context, snapshot) {
          return Checkbox(
              checked: snapshot.data,
              onChanged: (bool? value) {
                viewModel.updateLanguage(
                  language: language,
                  enabled: value ?? false,
                );
              },
              content: Wrap(
                direction: Axis.horizontal,
                spacing: 6,
                children: [
                  Flag.fromCode(language.flagCode, height: 21, width: 21),
                  Text(language.displayName),
                ],
              ));
        });
  }
}

class ChannelTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final finalValue = newValue.text.toLowerCase().replaceAll(" ", "");
    return TextEditingValue(
      text: finalValue,
      selection: finalValue == newValue.text.toLowerCase()
          ? newValue.selection
          : oldValue.selection,
    );
  }
}
