import 'package:fluent_ui/fluent_ui.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:provider/provider.dart';

class VolumeControl extends StatelessWidget {
  const VolumeControl({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = context.read<Config>();
    final volume = context
        .select((Config config) => config.chatToSpeechConfiguration.volume);

    return Row(
      children: [
        const Icon(FluentIcons.volume2),
        const SizedBox(width: 8.0),
        Slider(
          onChanged: (double value) {
            config.setVolume(value);
          },
          value: volume,
          max: 100,
          min: 0,
        ),
      ],
    );
  }
}
