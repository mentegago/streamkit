import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Settings button (centered horizontally)
        Align(
          alignment: Alignment.bottomCenter,
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/settings',
              );
            },
            style: TextButton.styleFrom(padding: const EdgeInsets.all(18)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings),
                SizedBox(width: 8),
                Text("Settings"),
              ],
            ),
          ),
        ),
        // Volume control (right side)
        const Positioned(
          right: 0,
          bottom: 0,
          child: _VolumeControl(),
        ),
      ],
    );
  }
}

class _VolumeControl extends HookWidget {
  const _VolumeControl();

  @override
  Widget build(BuildContext context) {
    final volume = context.select(
      (Config config) => config.chatToSpeechConfiguration.volume,
    );
    final isExpanded = useState(false);

    IconData getVolumeIcon() {
      if (volume == 0) return Icons.volume_off;
      if (volume < 50) return Icons.volume_down;
      return Icons.volume_up;
    }

    return SizedBox(
      width: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Expanded volume slider (appears above the button)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    animation,
                  ),
                  child: child,
                ),
              );
            },
            child: isExpanded.value
                ? Container(
                    width: 60,
                    height: 240,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${volume.round()}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: -1,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6),
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 12),
                              ),
                              child: Slider(
                                value: volume,
                                min: 0,
                                max: 100,
                                onChanged: (value) {
                                  context.read<Config>().setVolume(value);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Volume button
          Material(
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                isExpanded.value = !isExpanded.value;
              },
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  getVolumeIcon(),
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
