import 'package:flutter/material.dart';

class AccountBox extends StatelessWidget {
  const AccountBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundImage: NetworkImage(
              "https://static-cdn.jtvnw.net/jtv_user_pictures/d533fcca-5543-4b30-9199-ab708a536478-profile_image-70x70.png"),
        ),
        const SizedBox(
          width: 8,
        ),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("mentegagoreng"),
              Opacity(
                opacity: 0.5,
                child: Text("Twitch Account"),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              fixedSize: const Size.fromHeight(38)),
          child: const Text("Change Channel"),
        ),
      ],
    );
  }
}
