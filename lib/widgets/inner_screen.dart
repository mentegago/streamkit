import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:streamkit_tts/widgets/window_container.dart';

class InnerScreen extends HookWidget {
  final String title;
  final List<Widget> children;

  const InnerScreen({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scrollController = useScrollController();

    return Scaffold(
      body: WindowContainer(
        showWindowButtons: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    runSpacing: 24.0,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 48.0, left: 8.0),
                        child: Text(
                          title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...children,
                      const SizedBox(
                        width: 1,
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
                padding: const EdgeInsets.only(top: 48.0),
                margin: const EdgeInsets.only(right: 16.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton.filledTonal(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
