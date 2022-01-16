import 'package:fluent_ui/fluent_ui.dart';
import 'package:streamkit/app_config.dart';
import 'package:streamkit/screens/home/home_vm.dart';
import 'package:system_theme/system_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:streamkit/screens/home/home.dart';
import 'package:streamkit/screens/chat_to_speech/chat_to_speech.dart';
import 'package:streamkit/screens/chat_to_speech/chat_to_speech_vm.dart';

import 'package:streamkit/modules/chat_to_speech/chat_to_speech_module.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemTheme.accentInstance.load();
  await AppConfig.loadConfigurations();

  runApp(const MyApp());

  doWhenWindowReady(() {
    final win = appWindow;
    win.minSize = const Size(500, 500);
    win.size = const Size(1200, 700);
    win.alignment = Alignment.center;
    win.title = "Mentega StreamKit";
    win.show();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int index = 0;
  final HomeViewModel _homeViewModel;
  final ChatToSpeechViewModel _chatToSpeechViewModel;
  final ChatToSpeechModule _chatToSpeechModule;

  MyAppState._({
    required HomeViewModel homeViewModel,
    required ChatToSpeechModule chatToSpeechModule,
    required ChatToSpeechViewModel chatToSpeechViewModel,
  })  : _homeViewModel = homeViewModel,
        _chatToSpeechModule = chatToSpeechModule,
        _chatToSpeechViewModel = chatToSpeechViewModel;

  factory MyAppState() {
    final configurations = AppConfig.configurations;
    final chatToSpeechModule = ChatToSpeechModule(
      onConfigurationChanged: (configuration) {
        AppConfig.saveConfigurations(
          configurations.copyWith(chatToSpeech: configuration),
        );
      },
    );
    final chatToSpeechViewModel = ChatToSpeechViewModel(
      configuration: AppConfig.configurations.chatToSpeech,
      module: chatToSpeechModule,
    );
    final homeViewModel =
        HomeViewModel(chatToSpeechState: chatToSpeechModule.state);

    return MyAppState._(
      homeViewModel: homeViewModel,
      chatToSpeechModule: chatToSpeechModule,
      chatToSpeechViewModel: chatToSpeechViewModel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ThemeData(
      brightness: Brightness.dark,
      accentColor: SystemTheme.accentInstance.accent.toAccentColor(),
    );

    return FluentApp(
      title: "Mentega StreamKit",
      themeMode: ThemeMode.dark,
      theme: themeData,
      home: NavigationView(
        appBar: NavigationAppBar(
          height: 36,
          automaticallyImplyLeading: false,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: MoveWindow(
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    child: Row(
                      children: [
                        Container(
                            child: const Text("🧈",
                                style: TextStyle(fontSize: 24)),
                            margin: const EdgeInsets.only(bottom: 8, right: 8)),
                        const Text("Mentega StreamKit"),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                    ),
                  ),
                ),
              ),
              MinimizeWindowButton(
                  colors: WindowButtonColors(iconNormal: Colors.white)),
              MaximizeWindowButton(
                  colors: WindowButtonColors(iconNormal: Colors.white)),
              CloseWindowButton(
                  colors: WindowButtonColors(
                      iconNormal: Colors.white, mouseOver: Colors.red))
            ],
          ),
        ),
        content: NavigationBody(children: [
          Home(
            viewModel: _homeViewModel,
            onSelectModule: (index) {
              setState(() {
                this.index = index;
              });
            },
          ),
          ChatToSpeech(viewModel: _chatToSpeechViewModel),
        ], index: index),
        pane: NavigationPane(
          displayMode: PaneDisplayMode.auto,
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.home),
              title: const Text("Home"),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.speech),
              title: const Text("Chat Reader"),
            ),
          ],
          selected: index,
          onChanged: (newIndex) {
            setState(() {
              index = newIndex;
            });
          },
        ),
      ),
    );
  }
}
