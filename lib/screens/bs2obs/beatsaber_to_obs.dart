import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class BeatSaberToObs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(title: Text("Beat Saber to OBS")),
      content: Container(
        margin: const EdgeInsets.only(left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
                "Beat Saber to OBS is a web service that bridges BSDataPuller mod and OBS. It allows you to change your OBS scene based on whether you're in game or menu."),
            const SizedBox(height: 8),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                  "Click here for detailed instruction on how to setup Beat Saber to OBS.",
                  style: TextStyle(color: Colors.blue.lighter)),
            ),
            const SizedBox(height: 18),
            Button(
              child: const Padding(
                padding: EdgeInsets.all(2.0),
                child: Text("Go to Beat Saber to OBS"),
              ),
              onPressed: () {
                launch("https://mentegago.github.io/mentega-bs2obs");
              },
            ),
            const SizedBox(height: 32),
            const Text(
                "*In the future, this module will be directly integrated to StreamKit."),
          ],
        ),
      ),
    );
  }
}
