import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

import 'chat_to_speech_vm.dart';
import '../../modules/chat_to_speech/enums/language.dart';

class ChatToSpeech extends StatelessWidget {
  final ChatToSpeechViewModel viewModel;

  const ChatToSpeech({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
        header: const PageHeader(title: Text("Twitch Chat to Speech")),
        content: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextBox(
                inputFormatters: [ChannelTextFormatter()],
                header: "Channel name",
                controller: viewModel.channelController,
                placeholder:
                    "The name of the channel you want the TTS to read on",
              ),
              const SizedBox(height: 24),
              Wrap(
                direction: Axis.horizontal,
                spacing: 32,
                children: [
                  InfoLabel(
                    label: "Conditions",
                    child: Wrap(
                      direction: Axis.vertical,
                      spacing: 8,
                      children: [
                        StreamBuilder<bool>(
                            initialData: false,
                            stream: viewModel.readUsername,
                            builder: (context, snapshot) {
                              return Checkbox(
                                  checked: snapshot.data,
                                  onChanged: (bool? value) {
                                    viewModel.updateUsername(value ?? false);
                                  },
                                  content: const Text("Read username"));
                            }),
                        StreamBuilder<bool>(
                            initialData: false,
                            stream: viewModel.ignoreExclamationMark,
                            builder: (context, snapshot) {
                              return Checkbox(
                                  checked: snapshot.data,
                                  onChanged: (bool? value) {
                                    viewModel.updateIgnoreExclamationMark(
                                        value ?? false);
                                  },
                                  content: const Text(
                                      "Ignore messages starting with \"!\""));
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
                            viewModel: viewModel),
                        LanguageCheckbox(
                            language: Language.english, viewModel: viewModel),
                        LanguageCheckbox(
                            language: Language.japanese, viewModel: viewModel),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              StreamBuilder<ChatToSpeechState>(
                  stream: viewModel.state,
                  initialData: ChatToSpeechState.idle,
                  builder: (context, snapshot) {
                    if (snapshot.data == ChatToSpeechState.loading) {
                      return const Center(child: ProgressRing());
                    } else {
                      List<Widget> buttons = [
                        Expanded(
                          child: Button(
                            child: Text(snapshot.data == ChatToSpeechState.idle
                                ? "Connect"
                                : "Update configuration"),
                            onPressed: () {
                              if (viewModel.channelController.text.isEmpty) {
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
                              viewModel.setEnabled(true);
                            },
                          ),
                        )
                      ];

                      if (snapshot.data == ChatToSpeechState.connected) {
                        buttons.add(const SizedBox(width: 8));
                        buttons.add(IconButton(
                          icon: const Icon(FluentIcons.plug_disconnected),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => ContentDialog(
                                      title: const Text(
                                          'Disconnect from channel?'),
                                      content: Text(
                                          'Are you sure you want to disconnect from ${viewModel.channelController.text}?'),
                                      actions: [
                                        Button(
                                            child:
                                                const Text('Yes, disconnect'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              viewModel.setEnabled(false);
                                            }),
                                        Button(
                                            child: const Text('No'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            }),
                                      ],
                                    ));
                          },
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
              content: Text(language.displayName));
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
