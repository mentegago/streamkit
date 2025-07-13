import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:streamkit_tts/utils/mouse_back_recognizer.dart';
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
        showWindowButtons: true,
        child: _NavigationDetector(
          onNavigateBack: () => Navigator.pop(context),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
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
              const _CloseButton()
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.only(top: 48.0),
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
    );
  }
}

class _NavigationDetector extends StatelessWidget {
  final VoidCallback onNavigateBack;
  final Widget child;

  const _NavigationDetector({
    required this.onNavigateBack,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          onNavigateBack();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: <Type, GestureRecognizerFactory>{
          MouseBackRecognizer:
              GestureRecognizerFactoryWithHandlers<MouseBackRecognizer>(
            () => MouseBackRecognizer(),
            (instance) => instance.onTapDown = (_) => onNavigateBack(),
          ),
        },
        child: child,
      ),
    );
  }
}
