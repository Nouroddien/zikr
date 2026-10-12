import 'package:adhan/adhan.dart';

import '../../domain/entities/prayer_settings.dart';

class PrayerTimesService {
  const PrayerTimesService();

  PrayerSchedule calculate({
    required double latitude,
    required double longitude,
    required DateTime dateTime,
    PrayerCalculationMethod method = PrayerCalculationMethod.muslimWorldLeague,
    AsrJuristicMethod asrMethod = AsrJuristicMethod.standard,
    Set<PrayerName> notificationsEnabled = const {},
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final parameters = _parameters(method, asrMethod);
    final today = _calculateDay(coordinates, dateTime, parameters);
    final now = dateTime;

    final prayerOrder = <PrayerName>[
      PrayerName.fajr,
      PrayerName.dhuhr,
      PrayerName.asr,
      PrayerName.maghrib,
      PrayerName.isha,
    ];
    final nextToday = today.entries.where((entry) {
      return entry.name != PrayerName.sunrise && entry.time.isAfter(now);
    }).firstOrNull;
    final next =
        nextToday ??
        _calculateDay(
          coordinates,
          DateTime(dateTime.year, dateTime.month, dateTime.day + 1),
          parameters,
        ).entries.firstWhere((entry) => entry.name == PrayerName.fajr);

    final current = prayerOrder.reversed
        .map((name) => today.entries.firstWhere((entry) => entry.name == name))
        .where((entry) => !entry.time.isAfter(now))
        .firstOrNull;

    return PrayerSchedule(
      entries: today.entries,
      currentPrayer: current?.name ?? PrayerName.isha,
      nextPrayer: next.name,
      nextPrayerTime: next.time,
    );
  }

  List<PrayerTimeEntry> calculateDay({
    required double latitude,
    required double longitude,
    required DateTime date,
    PrayerCalculationMethod method = PrayerCalculationMethod.muslimWorldLeague,
    AsrJuristicMethod asrMethod = AsrJuristicMethod.standard,
    Set<PrayerName> notificationsEnabled = const {},
  }) {
    return _calculateDay(
      Coordinates(latitude, longitude),
      date,
      _parameters(method, asrMethod),
      notificationsEnabled,
    ).entries;
  }

  _DaySchedule _calculateDay(
    Coordinates coordinates,
    DateTime date,
    CalculationParameters parameters, [
    Set<PrayerName> notificationsEnabled = const {},
  ]) {
    final prayerTimes = PrayerTimes(
      coordinates,
      DateComponents.from(date),
      parameters,
    );

    PrayerTimeEntry entry(PrayerName name, DateTime? time) {
      if (time == null) {
        throw StateError('Calculated prayer time is unavailable: $name');
      }
      return PrayerTimeEntry(
        name: name,
        time: time,
        notificationEnabled:
            name != PrayerName.sunrise && notificationsEnabled.contains(name),
      );
    }

    return _DaySchedule([
      entry(PrayerName.fajr, prayerTimes.fajr),
      entry(PrayerName.sunrise, prayerTimes.sunrise),
      entry(PrayerName.dhuhr, prayerTimes.dhuhr),
      entry(PrayerName.asr, prayerTimes.asr),
      entry(PrayerName.maghrib, prayerTimes.maghrib),
      entry(PrayerName.isha, prayerTimes.isha),
    ]);
  }

  CalculationParameters _parameters(
    PrayerCalculationMethod method,
    AsrJuristicMethod asrMethod,
  ) {
    final parameters = switch (method) {
      PrayerCalculationMethod.muslimWorldLeague =>
        CalculationMethod.muslim_world_league.getParameters(),
      PrayerCalculationMethod.egyptian =>
        CalculationMethod.egyptian.getParameters(),
      PrayerCalculationMethod.karachi =>
        CalculationMethod.karachi.getParameters(),
      PrayerCalculationMethod.ummAlQura =>
        CalculationMethod.umm_al_qura.getParameters(),
      PrayerCalculationMethod.dubai => CalculationMethod.dubai.getParameters(),
      PrayerCalculationMethod.northAmerica =>
        CalculationMethod.north_america.getParameters(),
      PrayerCalculationMethod.kuwait =>
        CalculationMethod.kuwait.getParameters(),
      PrayerCalculationMethod.qatar => CalculationMethod.qatar.getParameters(),
      PrayerCalculationMethod.singapore =>
        CalculationMethod.singapore.getParameters(),
      PrayerCalculationMethod.turkey =>
        CalculationMethod.turkey.getParameters(),
      PrayerCalculationMethod.tehran =>
        CalculationMethod.tehran.getParameters(),
    };
    parameters.madhab = asrMethod == AsrJuristicMethod.hanafi
        ? Madhab.hanafi
        : Madhab.shafi;
    return parameters;
  }
}

class _DaySchedule {
  const _DaySchedule(this.entries);
  final List<PrayerTimeEntry> entries;
}
