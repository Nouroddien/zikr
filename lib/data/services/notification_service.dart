import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/app_settings.dart';
import '../../domain/entities/prayer_settings.dart';
import 'prayer_times_service.dart';

class NotificationService {
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    this.rollingWindowDays = 5,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _prayerIdBase = 1000;
  static const _reminderIdBase = 2000;
  static const prayerChannelId = 'prayer_times';
  static const azanChannelId = 'prayer_times_azan';
  static const remindersChannelId = 'azkar_reminders';

  final FlutterLocalNotificationsPlugin _plugin;
  final int rollingWindowDays;

  Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          prayerChannelId,
          'Prayer reminders',
          description: 'Local reminders for the five daily prayers.',
          importance: Importance.high,
        ),
      );
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          azanChannelId,
          'Prayer reminders with azan',
          description: 'Prayer reminders with the selected azan sound.',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('azan_placeholder'),
        ),
      );
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          remindersChannelId,
          'Azkar reminders',
          description: 'Scheduled morning, evening, and sleep azkar.',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  Future<void> refreshLocalTimezone() async {
    tzdata.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
  }

  Future<void> rescheduleEnabledNotifications(AppSettings settings) async {
    final now = DateTime.now();
    const prayerTimesService = PrayerTimesService();
    final prayerDays = [
      for (var offset = 0; offset < rollingWindowDays; offset++)
        prayerTimesService.calculateDay(
          latitude: settings.latitude,
          longitude: settings.longitude,
          date: DateTime(now.year, now.month, now.day + offset),
          method: settings.calculationMethod,
          asrMethod: settings.asrMethod,
          notificationsEnabled: settings.enabledPrayers,
        ),
    ];
    await schedulePrayerWindow(
      days: prayerDays,
      enabledPrayers: settings.enabledPrayers,
      azanSoundEnabled: settings.azanSoundEnabled,
      exactAlarmsAllowed: settings.exactAlarmsAllowed,
    );
    await scheduleAzkarReminders(
      settings: settings.reminderSettings,
      enabled: settings.azkarRemindersEnabled,
      exactAlarmsAllowed: settings.exactAlarmsAllowed,
    );
  }

  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (await android?.canScheduleExactNotifications() ?? false) return true;
    return await android?.requestExactAlarmsPermission() ?? false;
  }

  Future<bool> openNotificationSettings() => Geolocator.openAppSettings();

  Future<void> schedulePrayerWindow({
    required List<List<PrayerTimeEntry>> days,
    required Set<PrayerName> enabledPrayers,
    required bool azanSoundEnabled,
    required bool exactAlarmsAllowed,
  }) async {
    for (var day = 0; day < rollingWindowDays; day++) {
      for (var prayer = 0; prayer < PrayerName.values.length; prayer++) {
        await _plugin.cancel(id: _prayerIdBase + (day * 10) + prayer);
      }
    }

    final scheduleDays = days.take(rollingWindowDays).toList();
    for (var day = 0; day < scheduleDays.length; day++) {
      for (final entry in scheduleDays[day]) {
        if (entry.name == PrayerName.sunrise ||
            !enabledPrayers.contains(entry.name) ||
            !entry.time.isAfter(DateTime.now())) {
          continue;
        }
        final index = PrayerName.values.indexOf(entry.name);
        await _schedule(
          id: _prayerIdBase + (day * 10) + index,
          title: 'Prayer time',
          body: '${entry.name.name} prayer time has begun.',
          at: entry.time,
          exactAlarmsAllowed: exactAlarmsAllowed,
          prayer: true,
          azanSoundEnabled: azanSoundEnabled,
        );
      }
    }
  }

  Future<void> scheduleAzkarReminders({
    required ReminderSettings settings,
    required bool enabled,
    required bool exactAlarmsAllowed,
  }) async {
    for (var day = 0; day < rollingWindowDays; day++) {
      for (var reminder = 0; reminder < 3; reminder++) {
        await _plugin.cancel(id: _reminderIdBase + (day * 10) + reminder);
      }
    }
    if (!enabled) return;

    final reminders = [
      (name: 'Morning azkar', time: settings.morning),
      (name: 'Evening azkar', time: settings.evening),
      (name: 'Sleep azkar', time: settings.sleep),
    ];
    final now = DateTime.now();
    for (var day = 0; day < rollingWindowDays; day++) {
      final date = DateTime(now.year, now.month, now.day + day);
      for (var index = 0; index < reminders.length; index++) {
        final reminder = reminders[index];
        final when = DateTime(
          date.year,
          date.month,
          date.day,
          reminder.time.hour,
          reminder.time.minute,
        );
        if (!when.isAfter(now)) continue;
        await _schedule(
          id: _reminderIdBase + (day * 10) + index,
          title: reminder.name,
          body: 'Take a moment for your daily remembrance.',
          at: when,
          exactAlarmsAllowed: exactAlarmsAllowed,
          prayer: false,
          azanSoundEnabled: false,
        );
      }
    }
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required bool exactAlarmsAllowed,
    required bool prayer,
    required bool azanSoundEnabled,
  }) async {
    final useAzan = prayer && azanSoundEnabled;
    final channelId = useAzan
        ? azanChannelId
        : (prayer ? prayerChannelId : remindersChannelId);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          useAzan
              ? 'Prayer reminders with azan'
              : (prayer ? 'Prayer reminders' : 'Azkar reminders'),
          channelDescription: prayer
              ? 'Local reminders for prayer times.'
              : 'Scheduled reminders for daily azkar.',
          importance: prayer ? Importance.high : Importance.defaultImportance,
          priority: prayer ? Priority.high : Priority.defaultPriority,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          sound: useAzan ? 'azan_placeholder.wav' : null,
        ),
      ),
      androidScheduleMode: exactAlarmsAllowed
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
