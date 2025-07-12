import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/services/version_check_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AnnouncementInformation extends StatelessWidget {
  const AnnouncementInformation({super.key});

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
            ? Colors.deepOrange[500]
            : Colors.red[800];

    final icon = versionStatus.state == VersionState.upToDate
        ? Icons.info
        : versionStatus.state == VersionState.beta
            ? Icons.science_outlined
            : Icons.warning;

    final message = versionStatus.announcement ??
        (versionStatus.state == VersionState.outdated
            ? "StreamKit ${versionStatus.latestVersion} is now available!"
            : "You're running test version! If there are issues, consider downgrading.");

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
      offset: Offset(0, shouldShow ? 0.6 : -1.0),
      duration: Durations.medium1,
      curve: Curves.decelerate,
      child: shouldShow
          ? MaterialButton(
              onPressed: onPressed,
              key: const Key("message"),
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
