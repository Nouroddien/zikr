import 'package:flutter/material.dart';

import 'prayer_settings.dart';

enum RandomZekrFrequency { everyOpen, daily }

class AppSettings {
  const AppSettings({
    this.locale = const Locale('ar'),
    this.themeMode = ThemeMode.dark,
    this.calculationMethod = PrayerCalculationMethod.muslimWorldLeague,
    this.asrMethod = AsrJuristicMethod.standard,
    this.enabledPrayers = const {},
    this.azanSoundEnabled = false,
    this.azkarRemindersEnabled = false,
    this.exactAlarmsAllowed = false,
    this.reminderSettings = const ReminderSettings(
      morning: ReminderTime(hour: 6, minute: 0),
      evening: ReminderTime(hour: 18, minute: 0),
      sleep: ReminderTime(hour: 22, minute: 0),
    ),
    this.randomZekrFrequency = RandomZekrFrequency.everyOpen,
    this.latitude = 24.7136,
    this.longitude = 46.6753,
    this.cityName = 'الرياض',
  });

  final Locale locale;
  final ThemeMode themeMode;
  final PrayerCalculationMethod calculationMethod;
  final AsrJuristicMethod asrMethod;
  final Set<PrayerName> enabledPrayers;
  final bool azanSoundEnabled;
  final bool azkarRemindersEnabled;
  final bool exactAlarmsAllowed;
  final ReminderSettings reminderSettings;
  final RandomZekrFrequency randomZekrFrequency;
  final double latitude;
  final double longitude;
  final String cityName;

  AppSettings copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    PrayerCalculationMethod? calculationMethod,
    AsrJuristicMethod? asrMethod,
    Set<PrayerName>? enabledPrayers,
    bool? azanSoundEnabled,
    bool? azkarRemindersEnabled,
    bool? exactAlarmsAllowed,
    ReminderSettings? reminderSettings,
    RandomZekrFrequency? randomZekrFrequency,
    double? latitude,
    double? longitude,
    String? cityName,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      asrMethod: asrMethod ?? this.asrMethod,
      enabledPrayers: enabledPrayers ?? this.enabledPrayers,
      azanSoundEnabled: azanSoundEnabled ?? this.azanSoundEnabled,
      azkarRemindersEnabled:
          azkarRemindersEnabled ?? this.azkarRemindersEnabled,
      exactAlarmsAllowed: exactAlarmsAllowed ?? this.exactAlarmsAllowed,
      reminderSettings: reminderSettings ?? this.reminderSettings,
      randomZekrFrequency: randomZekrFrequency ?? this.randomZekrFrequency,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
    );
  }
}
