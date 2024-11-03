import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/services/version_check_service.dart';

class WindowContainer extends HookWidget {
  final Widget child;
  final bool showWindowButtons;

  const WindowContainer({
    super.key,
    required this.child,
    this.showWindowButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    final isHovered = useState(false);
    final version = context.select(
      (VersionCheckService version) => version.currentVersion,
    );

    return Stack(
      children: [
        child,
        WindowTitleBarBox(
          child: MouseRegion(
            onEnter: (event) => isHovered.value = true,
            onExit: (event) => isHovered.value = false,
            onHover: (event) => isHovered.value = true,
            child: Stack(
              children: [
                Center(
                  child: AnimatedOpacity(
                    duration: Durations.short1,
                    opacity: isHovered.value && showWindowButtons ? 0.6 : 0.0,
                    child: Text(
                      version == null ? "StreamKit" : "StreamKit $version",
                    ),
                  ),
                ),
                SizedBox(
                  child: Row(
                    children: [
                      Expanded(child: MoveWindow()),
                      Visibility(
                        visible: showWindowButtons,
                        child: _WindowButtons(),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WindowButtons extends StatelessWidget {
  final _buttonColors = WindowButtonColors(
    iconNormal: Colors.white,
    mouseOver: Colors.white.withAlpha(10),
    mouseDown: Colors.white.withAlpha(5),
    iconMouseOver: Colors.white,
    iconMouseDown: Colors.white,
  );

  final _closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: Colors.white,
    iconMouseOver: Colors.white,
  );

  _WindowButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: _buttonColors),
        MaximizeWindowButton(colors: _buttonColors),
        CloseWindowButton(colors: _closeButtonColors),
      ],
    );
  }
}
