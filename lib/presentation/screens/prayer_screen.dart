import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_content.dart';
import '../../data/providers/app_settings_provider.dart';
import '../../data/providers/notification_service_provider.dart';
import '../../data/services/location_service.dart';
import '../../data/services/prayer_times_service.dart';
import '../../domain/entities/prayer_settings.dart';
import '../../l10n/app_localizations.dart';
import 'main_shell.dart';
import 'notification_permission_screen.dart';
import 'screen_labels.dart';

class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen>
    with WidgetsBindingObserver {
  Timer? _refreshTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() => _now = DateTime.now());
      _rescheduleEnabledNotifications();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider);
    final service = const PrayerTimesService();
    final schedule = service.calculate(
      latitude: settings.latitude,
      longitude: settings.longitude,
      dateTime: _now,
      method: settings.calculationMethod,
      asrMethod: settings.asrMethod,
      notificationsEnabled: settings.enabledPrayers,
    );

    return SafeArea(
      child: ResponsiveContent(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 16, bottom: 20),
              sliver: SliverList.list(
                children: [
                  AppSectionTitle(
                    l10n.prayer,
                    trailing: IconButton(
                      tooltip: l10n.settings,
                      onPressed: () => _showPrayerSettings(),
                      icon: const Icon(Icons.tune),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: ActionChip(
                      avatar: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.teal,
                        size: 18,
                      ),
                      label: Text(settings.cityName),
                      onPressed: _chooseLocation,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      DateFormat.yMMMMEEEEd(settings.locale.languageCode)
                          .format(_now),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CurrentPrayerCard(
                    name: prayerLabel(l10n, schedule.currentPrayer),
                    time:
                        schedule.entries
                            .where(
                              (entry) => entry.name == schedule.currentPrayer,
                            )
                            .firstOrNull
                            ?.time ??
                        _now,
                    title: l10n.currentPrayer,
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Column(
                      children: [
                        for (final entry in schedule.entries)
                          _PrayerRow(
                            entry: entry,
                            isCurrent: entry.name == schedule.currentPrayer,
                            label: prayerLabel(l10n, entry.name),
                            onToggle: entry.name == PrayerName.sunrise
                                ? null
                                : (enabled) =>
                                      _toggleNotification(entry.name, enabled),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PrayerOptions(
                    calculationMethod: settings.calculationMethod,
                    asrMethod: settings.asrMethod,
                    onCalculationChanged: (value) async {
                      await ref
                          .read(appSettingsProvider.notifier)
                          .changeCalculationMethod(value);
                      await _rescheduleEnabledNotifications();
                    },
                    onAsrChanged: (value) async {
                      await ref
                          .read(appSettingsProvider.notifier)
                          .changeAsrMethod(value);
                      await _rescheduleEnabledNotifications();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleNotification(PrayerName name, bool enabled) async {
    if (enabled && !await _ensureNotificationPermission()) return;
    final controller = ref.read(appSettingsProvider.notifier);
    await controller.togglePrayer(name, enabled);
    await _rescheduleEnabledNotifications();
  }

  Future<bool> _ensureNotificationPermission() async {
    final granted = await ref
        .read(notificationServiceProvider)
        .requestNotificationPermission();
    if (granted) return true;
    if (!mounted) return false;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => NotificationPermissionScreen(
          service: ref.read(notificationServiceProvider),
        ),
      ),
    );
    return false;
  }

  Future<void> _rescheduleEnabledNotifications() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    final settings = ref.read(appSettingsProvider);
    final service = const PrayerTimesService();
    final now = DateTime.now();
    final days = [
      for (var offset = 0; offset < 5; offset++)
        service.calculateDay(
          latitude: settings.latitude,
          longitude: settings.longitude,
          date: DateTime(now.year, now.month, now.day + offset),
          method: settings.calculationMethod,
          asrMethod: settings.asrMethod,
          notificationsEnabled: settings.enabledPrayers,
        ),
    ];
    await ref
        .read(notificationServiceProvider)
        .schedulePrayerWindow(
          days: days,
          enabledPrayers: settings.enabledPrayers,
          azanSoundEnabled: settings.azanSoundEnabled,
          exactAlarmsAllowed: settings.exactAlarmsAllowed,
        );
  }

  Future<void> _chooseLocation() async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.my_location, color: AppColors.teal),
              title: Text(l10n.useCurrentLocation),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final location = await const LocationService()
                      .currentLocation();
                  await ref
                      .read(appSettingsProvider.notifier)
                      .setLocation(
                        latitude: location.latitude,
                        longitude: location.longitude,
                        cityName: location.cityName,
                      );
                  await _rescheduleEnabledNotifications();
                } on LocationPermissionDenied {
                  if (mounted) _showLocationFallback();
                }
              },
            ),
            for (final city in _cities)
              ListTile(
                leading: const Icon(
                  Icons.location_city_outlined,
                  color: AppColors.gold,
                ),
                title: Text(city.label(l10n)),
                onTap: () async {
                  await ref
                      .read(appSettingsProvider.notifier)
                      .setLocation(
                        latitude: city.latitude,
                        longitude: city.longitude,
                        cityName: city.label(l10n),
                      );
                  if (context.mounted) Navigator.pop(context);
                  await _rescheduleEnabledNotifications();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showLocationFallback() {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionRequired),
        content: Text(l10n.locationPermission),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              await const LocationService().openAppSettings();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  void _showPrayerSettings() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PrayerOptions(
                calculationMethod: ref
                    .read(appSettingsProvider)
                    .calculationMethod,
                asrMethod: ref.read(appSettingsProvider).asrMethod,
                onCalculationChanged: (value) async {
                  await ref
                      .read(appSettingsProvider.notifier)
                      .changeCalculationMethod(value);
                  if (context.mounted) Navigator.pop(context);
                  await _rescheduleEnabledNotifications();
                },
                onAsrChanged: (value) async {
                  await ref
                      .read(appSettingsProvider.notifier)
                      .changeAsrMethod(value);
                  if (context.mounted) Navigator.pop(context);
                  await _rescheduleEnabledNotifications();
                },
              ),
              const SizedBox(height: 12),
              Text(l10n.scholarReview, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.entry,
    required this.isCurrent,
    required this.label,
    required this.onToggle,
  });

  final PrayerTimeEntry entry;
  final bool isCurrent;
  final String label;
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isCurrent
          ? AppColors.gold.withValues(alpha: 0.08)
          : Colors.transparent,
      child: ListTile(
        leading: Icon(
          _prayerIcon(entry.name),
          color: isCurrent ? AppColors.gold : AppColors.muted,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? AppColors.gold : null,
          ),
        ),
        trailing: SizedBox(
          width: 104,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    DateFormat.jm().format(entry.time),
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.w700 : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (onToggle == null)
                const Icon(Icons.notifications_off_outlined, size: 19)
              else
                Transform.scale(
                  scale: 0.78,
                  child: Switch(
                    value: entry.notificationEnabled,
                    onChanged: onToggle,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _prayerIcon(PrayerName name) => switch (name) {
  PrayerName.fajr => Icons.nightlight_outlined,
  PrayerName.sunrise => Icons.wb_sunny_outlined,
  PrayerName.dhuhr => Icons.wb_sunny_outlined,
  PrayerName.asr => Icons.nightlight_outlined,
  PrayerName.maghrib => Icons.wb_twilight,
  PrayerName.isha => Icons.nightlight_outlined,
};

class _CurrentPrayerCard extends StatelessWidget {
  const _CurrentPrayerCard({
    required this.name,
    required this.time,
    required this.title,
  });

  final String name;
  final DateTime time;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.ocean],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 29,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            DateFormat.jm().format(time),
            style: const TextStyle(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _PrayerOptions extends StatelessWidget {
  const _PrayerOptions({
    required this.calculationMethod,
    required this.asrMethod,
    required this.onCalculationChanged,
    required this.onAsrChanged,
  });

  final PrayerCalculationMethod calculationMethod;
  final AsrJuristicMethod asrMethod;
  final ValueChanged<PrayerCalculationMethod> onCalculationChanged;
  final ValueChanged<AsrJuristicMethod> onAsrChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        DropdownButtonFormField<PrayerCalculationMethod>(
          isExpanded: true,
          initialValue: calculationMethod,
          decoration: InputDecoration(labelText: l10n.calculationMethod),
          items: [
            for (final method in PrayerCalculationMethod.values)
              DropdownMenuItem(
                value: method,
                child: Text(
                  _methodLabel(method),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) {
            if (value != null) onCalculationChanged(value);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<AsrJuristicMethod>(
          initialValue: asrMethod,
          decoration: InputDecoration(labelText: l10n.asrMethod),
          items: [
            DropdownMenuItem(
              value: AsrJuristicMethod.standard,
              child: Text(l10n.standard),
            ),
            DropdownMenuItem(
              value: AsrJuristicMethod.hanafi,
              child: Text(l10n.hanafi),
            ),
          ],
          onChanged: (value) {
            if (value != null) onAsrChanged(value);
          },
        ),
      ],
    );
  }
}

String _methodLabel(PrayerCalculationMethod method) => switch (method) {
  PrayerCalculationMethod.muslimWorldLeague => 'Muslim World League',
  PrayerCalculationMethod.egyptian => 'Egyptian General Authority',
  PrayerCalculationMethod.karachi => 'University of Islamic Sciences, Karachi',
  PrayerCalculationMethod.ummAlQura => 'Umm al-Qura',
  PrayerCalculationMethod.dubai => 'Dubai',
  PrayerCalculationMethod.northAmerica => 'ISNA',
  PrayerCalculationMethod.kuwait => 'Kuwait',
  PrayerCalculationMethod.qatar => 'Qatar',
  PrayerCalculationMethod.singapore => 'Singapore',
  PrayerCalculationMethod.turkey => 'Turkey',
  PrayerCalculationMethod.tehran => 'Tehran',
};

class _CityOption {
  const _CityOption(this.key, this.latitude, this.longitude);
  final String key;
  final double latitude;
  final double longitude;

  String label(AppLocalizations l10n) => switch (key) {
    'riyadh' => l10n.riyadh,
    'makkah' => l10n.makkah,
    'cairo' => l10n.cairo,
    'istanbul' => l10n.istanbul,
    'london' => l10n.london,
    'newYork' => l10n.newYork,
    _ => key,
  };
}

const _cities = [
  _CityOption('riyadh', 24.7136, 46.6753),
  _CityOption('makkah', 21.3891, 39.8579),
  _CityOption('cairo', 30.0444, 31.2357),
  _CityOption('istanbul', 41.0082, 28.9784),
  _CityOption('london', 51.5072, -0.1276),
  _CityOption('newYork', 40.7128, -74.0060),
];
