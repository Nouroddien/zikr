import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/entities/prayer_settings.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('SharedPreferences must be provided at startup.'),
);

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

class AppSettingsController extends Notifier<AppSettings> {
  late SharedPreferences _preferences;

  @override
  AppSettings build() {
    _preferences = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      locale: Locale(_preferences.getString('locale') ?? 'ar'),
      themeMode: ThemeMode.values.byName(
        _preferences.getString('theme') ?? 'dark',
      ),
      calculationMethod: PrayerCalculationMethod.values.byName(
        _preferences.getString('calculationMethod') ?? 'muslimWorldLeague',
      ),
      asrMethod: AsrJuristicMethod.values.byName(
        _preferences.getString('asrMethod') ?? 'standard',
      ),
      enabledPrayers: (_preferences.getStringList('enabledPrayers') ?? [])
          .map(PrayerName.values.byName)
          .toSet(),
      azanSoundEnabled: _preferences.getBool('azanSoundEnabled') ?? false,
      azkarRemindersEnabled:
          _preferences.getBool('azkarRemindersEnabled') ?? false,
      exactAlarmsAllowed: _preferences.getBool('exactAlarmsAllowed') ?? false,
      reminderSettings: ReminderSettings(
        morning: _readReminder('morningReminder', 6, 0),
        evening: _readReminder('eveningReminder', 18, 0),
        sleep: _readReminder('sleepReminder', 22, 0),
      ),
      randomZekrFrequency: RandomZekrFrequency.values.byName(
        _preferences.getString('randomZekrFrequency') ?? 'everyOpen',
      ),
      latitude: _preferences.getDouble('latitude') ?? 24.7136,
      longitude: _preferences.getDouble('longitude') ?? 46.6753,
      cityName: _preferences.getString('cityName') ?? 'الرياض',
    );
  }

  ReminderTime _readReminder(String key, int defaultHour, int defaultMinute) {
    final saved = _preferences.getString(key);
    if (saved == null) {
      return ReminderTime(hour: defaultHour, minute: defaultMinute);
    }
    final decoded = jsonDecode(saved);
    if (decoded is! Map<String, dynamic> ||
        decoded['hour'] is! int ||
        decoded['minute'] is! int) {
      throw FormatException('Invalid saved reminder time: $key');
    }
    return ReminderTime(
      hour: decoded['hour'] as int,
      minute: decoded['minute'] as int,
    );
  }

  Future<void> changeLocale(Locale value) async {
    await _preferences.setString('locale', value.languageCode);
    state = state.copyWith(locale: value);
  }

  Future<void> changeTheme(ThemeMode value) async {
    await _preferences.setString('theme', value.name);
    state = state.copyWith(themeMode: value);
  }

  Future<void> changeCalculationMethod(PrayerCalculationMethod value) async {
    await _preferences.setString('calculationMethod', value.name);
    state = state.copyWith(calculationMethod: value);
  }

  Future<void> changeAsrMethod(AsrJuristicMethod value) async {
    await _preferences.setString('asrMethod', value.name);
    state = state.copyWith(asrMethod: value);
  }

  Future<void> togglePrayer(PrayerName prayer, bool enabled) async {
    if (prayer == PrayerName.sunrise) return;
    final updated = {...state.enabledPrayers};
    enabled ? updated.add(prayer) : updated.remove(prayer);
    await _preferences.setStringList(
      'enabledPrayers',
      updated.map((entry) => entry.name).toList(),
    );
    state = state.copyWith(enabledPrayers: updated);
  }

  Future<void> setAzanSound(bool value) async {
    await _preferences.setBool('azanSoundEnabled', value);
    state = state.copyWith(azanSoundEnabled: value);
  }

  Future<void> setAzkarReminders(bool value) async {
    await _preferences.setBool('azkarRemindersEnabled', value);
    state = state.copyWith(azkarRemindersEnabled: value);
  }

  Future<void> setExactAlarmsAllowed(bool value) async {
    await _preferences.setBool('exactAlarmsAllowed', value);
    state = state.copyWith(exactAlarmsAllowed: value);
  }

  Future<void> setReminder(String name, ReminderTime value) async {
    await _preferences.setString(
      '${name}Reminder',
      jsonEncode({'hour': value.hour, 'minute': value.minute}),
    );
    state = state.copyWith(
      reminderSettings: switch (name) {
        'morning' => ReminderSettings(
          morning: value,
          evening: state.reminderSettings.evening,
          sleep: state.reminderSettings.sleep,
        ),
        'evening' => ReminderSettings(
          morning: state.reminderSettings.morning,
          evening: value,
          sleep: state.reminderSettings.sleep,
        ),
        'sleep' => ReminderSettings(
          morning: state.reminderSettings.morning,
          evening: state.reminderSettings.evening,
          sleep: value,
        ),
        _ => throw ArgumentError.value(name, 'name', 'Unknown reminder'),
      },
    );
  }

  Future<void> changeRandomFrequency(RandomZekrFrequency value) async {
    await _preferences.setString('randomZekrFrequency', value.name);
    state = state.copyWith(randomZekrFrequency: value);
  }

  Future<void> setLocation({
    required double latitude,
    required double longitude,
    required String cityName,
  }) async {
    await _preferences.setDouble('latitude', latitude);
    await _preferences.setDouble('longitude', longitude);
    await _preferences.setString('cityName', cityName);
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      cityName: cityName,
    );
  }
}
