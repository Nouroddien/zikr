import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class BatteryHelpScreen extends StatelessWidget {
  const BatteryHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.batteryTip)),
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
                    Icons.battery_saver_outlined,
                    color: AppColors.teal,
                    size: 64,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.batteryTipBody,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () async {
                      await Geolocator.openAppSettings();
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
