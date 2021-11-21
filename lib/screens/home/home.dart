import 'package:fluent_ui/fluent_ui.dart';
import 'package:streamkit/modules/stream_kit_module.dart';
import 'package:streamkit/screens/chat_to_speech/chat_to_speech_vm.dart';
import 'package:streamkit/screens/home/home_vm.dart';

class Home extends StatelessWidget {
  final HomeViewModel _viewModel;
  final Function(int)? _onSelectModule;

  const Home({Key? key, required viewModel, Function(int)? onSelectModule})
      : _viewModel = viewModel,
        _onSelectModule = onSelectModule,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
        header: const PageHeader(title: Text("StreamKit Status")),
        content: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text("Below are the status of all StreamKit modules."),
              const SizedBox(height: 12),
              Wrap(
                direction: Axis.horizontal,
                spacing: 12,
                runSpacing: 12,
                children: [
                  StreamBuilder<ModuleState>(
                      stream: _viewModel.chatToSpeechState,
                      builder: (context, snapshot) {
                        return ModuleStatusBox(
                          icon: FluentIcons.speech,
                          title: "Chat Reader",
                          status: snapshot.data == ModuleState.active,
                          onSelectModule: () {
                            _onSelectModule?.call(1);
                          },
                        );
                      }),
                ],
              )
            ],
          ),
        ));
  }
}

class ModuleStatusBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool status;
  final Function? onSelectModule;

  const ModuleStatusBox({
    Key? key,
    required this.icon,
    required this.title,
    required this.status,
    this.onSelectModule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: () {
        onSelectModule?.call();
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
        child: Column(
          children: [
            Icon(icon, size: 42),
            const SizedBox(height: 12),
            Text(title),
            ModuleStatusInfo(status: status),
          ],
        ),
      ),
    );
  }
}

class ModuleStatusInfo extends StatelessWidget {
  final bool _status;
  const ModuleStatusInfo({Key? key, required bool status})
      : _status = status,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _status ? Colors.green : Colors.red,
      ),
      child: Text(
        _status ? "Active" : "Inactive",
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
