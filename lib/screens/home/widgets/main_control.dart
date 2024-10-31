import 'package:flutter/material.dart';
import 'package:streamkit_tts/screens/home/widgets/account_box.dart';

class MainControl extends StatelessWidget {
  const MainControl({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(20),
          ),
          width: 600,
          padding: const EdgeInsets.all(12),
          child: const AccountBox(),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryFixedDim,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              fixedSize: const Size(600, 38)),
          child: const Text("Start Chat Reader"),
        ),
      ],
    );
  }
}
