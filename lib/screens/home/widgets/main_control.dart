import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/screens/home/widgets/account_box.dart';
import 'package:streamkit_tts/services/composers/composer_service.dart';

class MainControl extends StatelessWidget {
  const MainControl({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          borderRadius: BorderRadius.circular(20),
          elevation: 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            width: 600,
            padding: const EdgeInsets.all(12),
            child: const AccountBox(),
          ),
        ),
        const SizedBox(height: 12),
        const _StartButton(),
      ],
    );
  }
}

class _StartButton extends HookWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    final composer = context.read<ComposerService>();
    final status = useState<ComposerStatus>(ComposerStatus.inactive);
    const height = 42.0;

    useEffect(() {
      composer.getStatusStream().listen((composerStatus) {
        status.value = composerStatus;
      });

      return null;
    }, []);

    switch (status.value) {
      case ComposerStatus.inactive:
        return TextButton(
          onPressed: () {
            context.read<Config>().setEnabled(true);
          },
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            fixedSize: const Size(600, height),
          ),
          child: const Text("Start Chat Reader"),
        );

      case ComposerStatus.loading:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const SizedBox(
            height: height,
            width: height,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          ),
        );

      case ComposerStatus.active:
        return TextButton(
          onPressed: () {
            context.read<Config>().setEnabled(false);
          },
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            fixedSize: const Size(600, height),
          ),
          child: const Text("Stop Chat Reader"),
        );
    }
  }
}
