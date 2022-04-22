# 🧈 Mentega StreamKit 🧈
**This app is still in very early stage. There will be a lot of bugs.**

![Screenshot](screenshots/streamkit.jpg)

## Features
- Twitch chat text-to-speech with multilingual (Indonesian, English, and Japanese) support. StreamKit automatically detects the language of each message and use the appropriate TTS voice for the language.
- Shortcut to [Beat Saber to OBS](https://github.com/mentegago/mentega-bs2obs).

## Language detection
The language detection algorithm is using n-gram based language detection algorithm. The models are trained from actual Twitch streamer's chat, which allows it to detect commonly used abbreviations and slangs. I kind of made a mistake and accidentally removed all the whitespaces when creating the n-gram models, but it seems to work regardless, so, there's that. Might fix it later, but that would mean I need to train it again.

## Building
This app is written with [Flutter on Desktop](https://flutter.dev/multi-platform/desktop). You'll need **Flutter** SDK to be installed as well as everything [required to build a Flutter Windows app](https://docs.flutter.dev/desktop#additional-windows-requirements). 

This app has not been tested to run on macOS or Linux, however, the libraries used in this project are all crossplatform, so I don't think there should be any issue building for other platforms.