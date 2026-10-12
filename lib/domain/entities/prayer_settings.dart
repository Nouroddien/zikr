enum PrayerCalculationMethod {
  muslimWorldLeague,
  egyptian,
  karachi,
  ummAlQura,
  dubai,
  northAmerica,
  kuwait,
  qatar,
  singapore,
  turkey,
  tehran,
}

enum AsrJuristicMethod { standard, hanafi }

enum PrayerName { fajr, sunrise, dhuhr, asr, maghrib, isha }

class PrayerTimeEntry {
  const PrayerTimeEntry({
    required this.name,
    required this.time,
    required this.notificationEnabled,
  });

  final PrayerName name;
  final DateTime time;
  final bool notificationEnabled;
}

class PrayerSchedule {
  const PrayerSchedule({
    required this.entries,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.nextPrayerTime,
  });

  final List<PrayerTimeEntry> entries;
  final PrayerName currentPrayer;
  final PrayerName nextPrayer;
  final DateTime nextPrayerTime;
}

class ReminderTime {
  const ReminderTime({required this.hour, required this.minute});

  final int hour;
  final int minute;
}

class ReminderSettings {
  const ReminderSettings({
    required this.morning,
    required this.evening,
    required this.sleep,
  });

  final ReminderTime morning;
  final ReminderTime evening;
  final ReminderTime sleep;
}
