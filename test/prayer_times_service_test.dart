import 'package:flutter_test/flutter_test.dart';
import 'package:zikr/data/services/prayer_times_service.dart';
import 'package:zikr/domain/entities/prayer_settings.dart';

void main() {
  const service = PrayerTimesService();
  const latitude = 24.7136;
  const longitude = 46.6753;

  test('calculates all prayer times including sunrise and next prayer', () {
    final schedule = service.calculate(
      latitude: latitude,
      longitude: longitude,
      dateTime: DateTime(2026, 10, 12, 12),
      notificationsEnabled: PrayerName.values.toSet(),
    );

    expect(schedule.entries, hasLength(6));
    expect(schedule.entries.map((entry) => entry.name), PrayerName.values);
    expect(
      schedule.entries
          .firstWhere((entry) => entry.name == PrayerName.sunrise)
          .notificationEnabled,
      isFalse,
    );
    expect(schedule.nextPrayer, PrayerName.asr);
    expect(schedule.nextPrayerTime.isAfter(DateTime(2026, 10, 12, 12)), isTrue);
    expect(schedule.currentPrayer, PrayerName.dhuhr);
  });

  test('supports every configured calculation method', () {
    for (final method in PrayerCalculationMethod.values) {
      final schedule = service.calculate(
        latitude: latitude,
        longitude: longitude,
        dateTime: DateTime(2026, 10, 12, 12),
        method: method,
      );
      expect(schedule.entries, hasLength(6), reason: method.name);
    }
  });

  test('supports both standard and Hanafi Asr calculations', () {
    final date = DateTime(2026, 10, 12);
    final standard = service.calculateDay(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );
    final hanafi = service.calculateDay(
      latitude: latitude,
      longitude: longitude,
      date: date,
      asrMethod: AsrJuristicMethod.hanafi,
    );

    final standardAsr = standard
        .firstWhere((entry) => entry.name == PrayerName.asr)
        .time;
    final hanafiAsr = hanafi
        .firstWhere((entry) => entry.name == PrayerName.asr)
        .time;
    expect(hanafiAsr.isAfter(standardAsr), isTrue);
  });
}
