import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:streamkit_tts/screens/home/widgets/announcement_information.dart';
import 'package:streamkit_tts/screens/home/widgets/footer.dart';
import 'package:streamkit_tts/screens/home/widgets/main_control.dart';
import 'package:streamkit_tts/widgets/window_container.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: WindowContainer(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: AnnouncementInformation(),
              ),
              Align(
                alignment: Alignment.center,
                child: MainControl(),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Footer(),
              )
            ],
          ),
        ),
      ),
      // backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    );
  }
}
