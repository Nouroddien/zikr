import '../../domain/entities/prayer_settings.dart';
import '../../l10n/app_localizations.dart';

String prayerLabel(AppLocalizations l10n, PrayerName prayer) =>
    switch (prayer) {
      PrayerName.fajr => l10n.fajr,
      PrayerName.sunrise => l10n.sunrise,
      PrayerName.dhuhr => l10n.dhuhr,
      PrayerName.asr => l10n.asr,
      PrayerName.maghrib => l10n.maghrib,
      PrayerName.isha => l10n.isha,
    };

String categoryLabel(AppLocalizations l10n, String category) =>
    switch (category) {
      'morning' => l10n.morning,
      'evening' => l10n.evening,
      'after_prayer' => l10n.afterPrayer,
      'sleep' => l10n.sleep,
      'waking' => l10n.waking,
      'general' => l10n.general,
      _ => category,
    };
