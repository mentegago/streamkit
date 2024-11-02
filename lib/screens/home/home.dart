import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/screens/home/widgets/main_control.dart';
import 'package:streamkit_tts/services/version_check_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: _AnnouncementInformation(),
            ),
            Align(
              alignment: Alignment.center,
              child: MainControl(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _SettingsButton(),
            )
          ],
        ),
      ),
      // backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
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
          SizedBox(
            width: 8,
          ),
          Text("Settings"),
        ],
      ),
    );
  }
}

class _AnnouncementInformation extends StatelessWidget {
  const _AnnouncementInformation();

  @override
  Widget build(BuildContext context) {
    final versionStatus =
        context.select((VersionCheckService service) => service.status);

    final shouldShow = versionStatus.state == VersionState.outdated ||
        versionStatus.state == VersionState.beta ||
        versionStatus.announcement != null;

    final color = versionStatus.state == VersionState.upToDate
        ? Colors.green[800]
        : versionStatus.state == VersionState.beta
            ? Colors.deepOrange[800]
            : Colors.red[800];

    final icon = versionStatus.state == VersionState.upToDate
        ? Icons.info
        : Icons.warning;

    final message = versionStatus.announcement ??
        (versionStatus.state == VersionState.outdated
            ? "StreamKit ${versionStatus.latestVersion} is now available!"
            : "You're running prerelease version!");

    String? actionUrl;
    String? actionMessage;

    switch (versionStatus.state) {
      case VersionState.beta:
        actionUrl = versionStatus.announcementUrl ?? versionStatus.downloadUrl;
        actionMessage =
            versionStatus.announcementUrl != null ? "Details" : "Downgrade";
        break;

      case VersionState.outdated:
        actionUrl = versionStatus.announcementUrl ?? versionStatus.downloadUrl;
        actionMessage =
            versionStatus.announcementUrl != null ? "Details" : "Update";
        break;

      case VersionState.upToDate:
        actionUrl = versionStatus.announcementUrl;
        actionMessage = actionUrl != null ? "Details" : null;
        break;

      default:
        break;
    }

    onPressed() {
      if (actionUrl != null) {
        launchUrlString(actionUrl, mode: LaunchMode.externalApplication);
      }
    }

    return AnimatedSlide(
      offset: Offset(0, shouldShow ? 0.0 : -1.0),
      duration: Durations.medium1,
      curve: Curves.decelerate,
      child: shouldShow
          ? MaterialButton(
              onPressed: onPressed,
              key: const Key("message"),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(8.0),
              //   color: color,
              // ),
              color: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 8.0),
                  Expanded(child: Text(message)),
                  if (actionUrl != null && actionMessage != null)
                    TextButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onPressed,
                      child: Text(actionMessage),
                    ),
                ],
              ),
            )
          : const SizedBox(),
    );
  }
}
