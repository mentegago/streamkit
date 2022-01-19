import 'package:fluent_ui/fluent_ui.dart';
import 'package:streamkit/app_config.dart';
import 'package:streamkit/modules/stream_kit_module.dart';
import 'package:streamkit/screens/home/home_vm.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  final HomeViewModel viewModel;
  final Function(int)? _onSelectModule;

  const Home({Key? key, required this.viewModel, Function(int)? onSelectModule})
      : _onSelectModule = onSelectModule,
        super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
        header: const PageHeader(title: Text("StreamKit Status")),
        content: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  StreamBuilder<Tuple2<VersionState, String?>>(
                      stream: widget.viewModel.isOutdated,
                      builder: (context, snapshot) {
                        final state =
                            snapshot.data?.item1 ?? VersionState.loading;
                        final latestVersion = snapshot.data?.item2 ?? "";
                        return Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                switch (state) {
                                  case VersionState.outdated:
                                    launch(widget.viewModel.downloadUrl);
                                    break;
                                  case VersionState.upToDate:
                                    launch(
                                        "https://www.youtube.com/watch?v=mW61VTLhNjQ");
                                    break;
                                  default:
                                    break;
                                }
                              },
                              child: InfoBar(
                                severity: state == VersionState.outdated
                                    ? InfoBarSeverity.warning
                                    : state == VersionState.upToDate
                                        ? InfoBarSeverity.success
                                        : InfoBarSeverity.info,
                                title: Text(state == VersionState.outdated
                                    ? "Outdated"
                                    : state == VersionState.upToDate
                                        ? "Up to date"
                                        : state == VersionState.error
                                            ? "Error"
                                            : "Loading"),
                                content: Text(state == VersionState.outdated
                                    ? "Your StreamKit is outdated. Click here to download the latest version ($latestVersion)."
                                    : state == VersionState.upToDate
                                        ? "Your StreamKit is up to date."
                                        : state == VersionState.error
                                            ? "Failed to get latest version of StreamKit."
                                            : "Getting latest version of StreamKit..."),
                              ),
                            ),
                          ),
                        );
                      }),
                  Wrap(
                    direction: Axis.horizontal,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      StreamBuilder<ModuleState>(
                        stream: widget.viewModel.chatToSpeechState,
                        builder: (context, snapshot) {
                          return ModuleStatusBox(
                            icon: FluentIcons.speech,
                            title: "Chat Reader",
                            state: snapshot.data ?? ModuleState.inactive,
                            onSelectModule: () {
                              widget._onSelectModule?.call(1);
                            },
                          );
                        },
                      ),
                      ModuleStatusBox(
                        icon: FluentIcons.streaming,
                        title: "Beat Saber 2 OBS",
                        onSelectModule: () {
                          widget._onSelectModule?.call(2);
                        },
                      )
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: StreamBuilder(
                    stream: widget.viewModel.currentVersion,
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return const Text("");
                      } else {
                        return GestureDetector(
                          onDoubleTap: () {
                            final dialog = ContentDialog(
                              title: const Text("Panci List"),
                              content: Text(AppConfig.panciList.join(", ")),
                              actions: [
                                Button(
                                    child: const Text("Ok"),
                                    onPressed: () =>
                                        Navigator.of(context).pop())
                              ],
                            );
                            showDialog(
                              context: context,
                              builder: (context) => dialog,
                            );
                          },
                          child: Text(
                            "🎈 ${snapshot.data}",
                          ),
                        );
                      }
                    }),
              )
            ],
          ),
        ));
  }
}

class ModuleStatusBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final ModuleState? state;
  final Function? onSelectModule;

  const ModuleStatusBox({
    Key? key,
    required this.icon,
    required this.title,
    this.state,
    this.onSelectModule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: () {
        onSelectModule?.call();
      },
      child: SizedBox(
        height: 120,
        width: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 42),
            const SizedBox(height: 12),
            Text(title),
            const SizedBox(height: 2),
            ModuleStatusInfo(state: state),
          ],
        ),
      ),
    );
  }
}

class ModuleStatusInfo extends StatelessWidget {
  final ModuleState? _state;
  const ModuleStatusInfo({Key? key, ModuleState? state})
      : _state = state,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: () {
          switch (_state) {
            case ModuleState.active:
              return Colors.green;
            case ModuleState.inactive:
              return Colors.red;
            case ModuleState.loading:
              return Colors.orange;
            case null:
              return Colors.blue;
          }
        }(),
      ),
      child: Text(
        () {
          switch (_state) {
            case ModuleState.active:
              return "Active";
            case ModuleState.inactive:
              return "Inactive";
            case ModuleState.loading:
              return "Loading";
            case null:
              return "Web";
          }
        }(),
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
