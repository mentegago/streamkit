import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:streamkit/modules/stream_kit_module.dart';
import 'package:streamkit/utils/twitch.dart';
import 'package:streamkit/screens/stream_kit_view_model.dart';

import '../../modules/chat_to_speech/chat_to_speech_module.dart';
import '../../configurations/chat_to_speech_configuration.dart';
import '../../modules/enums/language.dart';

enum ChatToSpeechConnectionState {
  idle,
  connected,
  loading,
}

class ChatToSpeechViewModel extends StreamKitViewModel {
  final ChatToSpeechModule _module;
  final TextEditingController channelController;

  final _readUsername = BehaviorSubject<bool>();
  final _ignoreExclamationMark = BehaviorSubject<bool>();
  final _languages = BehaviorSubject<Set<Language>>();
  final _isChanged = BehaviorSubject<bool>();

  ChatToSpeechConfiguration _currentConfiguration;

  Stream<ChatToSpeechConnectionState> get state => _module.state.map((event) {
        switch (event) {
          case ModuleState.active:
            return ChatToSpeechConnectionState.connected;
          case ModuleState.loading:
            return ChatToSpeechConnectionState.loading;
          case ModuleState.inactive:
            return ChatToSpeechConnectionState.idle;
        }
      });
  Stream<bool> get readUsername => _readUsername.stream;
  Stream<bool> get ignoreExclamationMark => _ignoreExclamationMark.stream;
  Stream<bool> language(Language language) =>
      _languages.map((languages) => languages.contains(language));
  Stream<String> get error => _module.error.map((event) {
        switch (event) {
          case TwitchError.timeout:
            return "Unable to join channel";
        }
      });
  Stream<bool> get isChanged => _isChanged.stream;

  void updateChangedState() {
    if (_currentConfiguration.readUsername != _readUsername.value) {
      _isChanged.add(true);
      return;
    }
    if (_currentConfiguration.ignoreExclamationMark !=
        _ignoreExclamationMark.value) {
      _isChanged.add(true);
      return;
    }
    if (!setEquals(_currentConfiguration.languages, _languages.value)) {
      _isChanged.add(true);
      return;
    }
    if (channelController.text != _currentConfiguration.channels.first) {
      _isChanged.add(true);
      return;
    }
    _isChanged.add(false);
  }

  ChatToSpeechViewModel._(
      {required this.channelController,
      required ChatToSpeechModule module,
      required ChatToSpeechConfiguration configuration})
      : _module = module,
        _currentConfiguration = configuration {
    channelController.addListener(() {
      updateChangedState();
    });
  }

  factory ChatToSpeechViewModel(
      {required ChatToSpeechConfiguration configuration,
      required ChatToSpeechModule module}) {
    final controller = TextEditingController(
        text: configuration.channels.isNotEmpty
            ? configuration.channels.first
            : "");
    ChatToSpeechViewModel viewModel = ChatToSpeechViewModel._(
      channelController: controller,
      module: module,
      configuration: configuration,
    );
    viewModel._readUsername.add(configuration.readUsername);
    viewModel._ignoreExclamationMark.add(configuration.ignoreExclamationMark);
    viewModel._languages.add({...configuration.languages});
    module.updateConfiguration(configuration);

    return viewModel;
  }

  ChatToSpeechConfiguration configuration({required bool enabled}) =>
      ChatToSpeechConfiguration(
        channels: [channelController.text],
        readUsername: _readUsername.value,
        ignoreExclamationMark: _ignoreExclamationMark.value,
        languages: _languages.value,
        enabled: enabled,
      );

  // Form update handling.
  void updateUsername(bool value) {
    _readUsername.add(value);
    updateChangedState();
  }

  void updateIgnoreExclamationMark(bool value) {
    _ignoreExclamationMark.add(value);
    updateChangedState();
  }

  void updateLanguage({required Language language, required bool enabled}) {
    final languages = {..._languages.value};
    if (enabled) {
      languages.add(language);
    } else {
      languages.remove(language);
    }

    _languages.add(languages); // Make the language list unique.
    updateChangedState();
  }

  void setEnabled(bool enabled) {
    final configuration = this.configuration(enabled: enabled);
    _module.updateConfiguration(configuration);

    _currentConfiguration = configuration;
    updateChangedState();
  }
}
