import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

import '../../modules/chat_to_speech/chat_to_speech_handler.dart';
import '../../modules/chat_to_speech/models/chat_to_speech_configuration.dart';
import '../../modules/chat_to_speech/enums/language.dart';

enum ChatToSpeechState {
  idle,
  connected,
  loading,
}

class ChatToSpeechViewModel {
  final ChatToSpeechHandler _handler = ChatToSpeechHandler();

  final _state = BehaviorSubject<ChatToSpeechState>();
  final _readUsername = BehaviorSubject<bool>();
  final _ignoreExclamationMark = BehaviorSubject<bool>();
  final _languages = BehaviorSubject<List<Language>>();

  Stream<ChatToSpeechState> get state => _state.stream;
  Stream<bool> get readUsername => _readUsername.stream;
  Stream<bool> get ignoreExclamationMark => _ignoreExclamationMark.stream;
  Stream<bool> language(Language language) =>
      _languages.map((languages) => languages.contains(language));

  TextEditingController channelController;
  bool _enabled = false;

  ChatToSpeechViewModel._(this.channelController);

  factory ChatToSpeechViewModel(ChatToSpeechConfiguration configuration) {
    ChatToSpeechViewModel viewModel = ChatToSpeechViewModel._(
        TextEditingController(
            text: configuration.channels.isNotEmpty
                ? configuration.channels.first
                : ""));

    viewModel._readUsername.add(configuration.readUsername);
    viewModel._ignoreExclamationMark.add(configuration.ignoreExclamationMark);
    viewModel._languages.add(configuration.languages);

    viewModel._handleStateChange();
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

  // Listen for possible state change.
  void _handleStateChange() {
    _handler.joinStream.listen((_) {
      _updateState();
    });
  }

  // Update state.
  void _updateState() {
    final connectedChannels = _handler.channels;
    final targetChannels = [channelController.text];

    if (!_enabled) {
      _state.add(ChatToSpeechState.idle);
      return;
    }

    if (connectedChannels.containsAll(targetChannels)) {
      _state.add(ChatToSpeechState.connected);
    } else {
      _state.add(ChatToSpeechState.loading);
    }
  }

  // Form update handling.
  void updateUsername(bool value) => _readUsername.add(value);
  void updateIgnoreExclamationMark(bool value) =>
      _ignoreExclamationMark.add(value);
  void updateLanguage({required Language language, required bool enabled}) {
    final languages = _languages.value;
    if (enabled) {
      languages.add(language);
    } else {
      languages.remove(language);
    }

    _languages
        .add(languages.toSet().toList()); // Make the language list unique.
  }

  void setEnabled(bool enabled) {
    final configuration = this.configuration(enabled: enabled);
    _handler.updateConfiguration(configuration);
    _enabled = enabled;

    if (enabled) {
      // Show the loading state even when not needed to give user the impression of action feedback.
      _state.add(ChatToSpeechState.loading);
      Future.delayed(const Duration(milliseconds: 100), () {
        _updateState();
      });

      Future.delayed(const Duration(seconds: 5), () {
        // JOIN timeout.
        if (_state.value == ChatToSpeechState.loading) {
          _state.add(ChatToSpeechState.idle);
        }
      });
    } else {
      _updateState();
    }
  }
}
