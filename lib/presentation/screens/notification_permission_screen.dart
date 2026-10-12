import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/notification_service.dart';
import '../../l10n/app_localizations.dart';

class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({required this.service, super.key});

  final NotificationService service;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_off_outlined,
                    color: AppColors.gold,
                    size: 64,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.permissionTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.permissionExplanation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () async {
                      await service.openNotificationSettings();
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.settings_outlined),
                    label: Text(l10n.openSettings),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
