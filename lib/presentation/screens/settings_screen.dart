import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_content.dart';
import '../../data/providers/app_settings_provider.dart';
import '../../data/providers/notification_service_provider.dart';
import '../../data/services/location_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/prayer_times_service.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/prayer_settings.dart';
import '../../l10n/app_localizations.dart';
import 'battery_help_screen.dart';
import 'main_shell.dart';
import 'notification_permission_screen.dart';
import '../../data/models/remote_prayer_city.dart';
import '../../data/providers/islamic_api_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider);
    final controller = ref.read(appSettingsProvider.notifier);
    return SafeArea(
      child: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 18),
          children: [
            Text(
              l10n.settings,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Card(
              child: Column(
                children: [
                  _ChoiceSetting<Locale>(
                    title: l10n.language,
                    selected: settings.locale,
                    options: [
                      (const Locale('ar'), l10n.arabic),
                      (const Locale('en'), l10n.english),
                    ],
                    onSelected: controller.changeLocale,
                  ),
                  const Divider(height: 1),
                  _ChoiceSetting<ThemeMode>(
                    title: l10n.theme,
                    selected: settings.themeMode,
                    options: [
                      (ThemeMode.system, l10n.system),
                      (ThemeMode.light, l10n.light),
                      (ThemeMode.dark, l10n.dark),
                    ],
                    onSelected: controller.changeTheme,
                  ),
                  const Divider(height: 1),
                  _ChoiceSetting<RandomZekrFrequency>(
                    title: l10n.randomFrequency,
                    selected: settings.randomZekrFrequency,
                    options: [
                      (RandomZekrFrequency.everyOpen, l10n.eachOpen),
                      (RandomZekrFrequency.daily, l10n.daily),
                    ],
                    onSelected: controller.changeRandomFrequency,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.prayer,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.teal,
                    ),
                    title: Text(l10n.chooseLocation),
                    subtitle: Text(settings.cityName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _chooseLocation(context, ref),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        DropdownButtonFormField<PrayerCalculationMethod>(
                          isExpanded: true,
                          initialValue: settings.calculationMethod,
                          decoration: InputDecoration(
                            labelText: l10n.calculationMethod,
                          ),
                          items: [
                            for (final method in PrayerCalculationMethod.values)
                              DropdownMenuItem(
                                value: method,
                                child: Text(
                                  _calculationMethodLabel(method),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (method) async {
                            if (method == null) return;
                            await controller.changeCalculationMethod(method);
                            await _reschedulePrayers(ref);
                          },
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<AsrJuristicMethod>(
                          initialValue: settings.asrMethod,
                          decoration: InputDecoration(
                            labelText: l10n.asrMethod,
                          ),
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
                          onChanged: (method) async {
                            if (method == null) return;
                            await controller.changeAsrMethod(method);
                            await _reschedulePrayers(ref);
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.gold,
                    ),
                    title: Text(l10n.azanSound),
                    value: settings.azanSoundEnabled,
                    onChanged: (value) async {
                      await controller.setAzanSound(value);
                      await _reschedulePrayers(ref);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.alarm_outlined),
                    title: Text(l10n.exactAlarm),
                    subtitle: Text(l10n.exactAlarmExplanation),
                    trailing: Icon(
                      settings.exactAlarmsAllowed
                          ? Icons.check_circle
                          : Icons.chevron_right,
                      color: settings.exactAlarmsAllowed
                          ? AppColors.teal
                          : null,
                    ),
                    onTap: () => _requestExactAlarm(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.tips_and_updates_outlined,
                      color: AppColors.teal,
                    ),
                    title: Text(l10n.batteryTip),
                    subtitle: Text(l10n.batteryTipBody),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const BatteryHelpScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.notifications,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.teal,
                    ),
                    title: Text(l10n.azkarReminders),
                    value: settings.azkarRemindersEnabled,
                    onChanged: (value) =>
                        _setAzkarReminders(context, ref, value),
                  ),
                  const Divider(height: 1),
                  _ReminderTile(
                    title: l10n.morningReminder,
                    value: settings.reminderSettings.morning,
                    onTap: () => _selectReminder(
                      context,
                      ref,
                      'morning',
                      settings.reminderSettings.morning,
                    ),
                  ),
                  _ReminderTile(
                    title: l10n.eveningReminder,
                    value: settings.reminderSettings.evening,
                    onTap: () => _selectReminder(
                      context,
                      ref,
                      'evening',
                      settings.reminderSettings.evening,
                    ),
                  ),
                  _ReminderTile(
                    title: l10n.sleepReminder,
                    value: settings.reminderSettings.sleep,
                    onTap: () => _selectReminder(
                      context,
                      ref,
                      'sleep',
                      settings.reminderSettings.sleep,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.scholarReview,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setAzkarReminders(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final service = ref.read(notificationServiceProvider);
    if (enabled && !await service.requestNotificationPermission()) {
      if (context.mounted) await _showNotificationDenied(context, service);
      return;
    }
    await ref.read(appSettingsProvider.notifier).setAzkarReminders(enabled);
    final settings = ref.read(appSettingsProvider);
    await service.scheduleAzkarReminders(
      settings: settings.reminderSettings,
      enabled: enabled,
      exactAlarmsAllowed: settings.exactAlarmsAllowed,
    );
  }

  Future<void> _selectReminder(
    BuildContext context,
    WidgetRef ref,
    String name,
    ReminderTime current,
  ) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (selected == null) return;
    await ref
        .read(appSettingsProvider.notifier)
        .setReminder(
          name,
          ReminderTime(hour: selected.hour, minute: selected.minute),
        );
    final settings = ref.read(appSettingsProvider);
    if (settings.azkarRemindersEnabled) {
      await ref
          .read(notificationServiceProvider)
          .scheduleAzkarReminders(
            settings: settings.reminderSettings,
            enabled: true,
            exactAlarmsAllowed: settings.exactAlarmsAllowed,
          );
    }
  }

  Future<void> _requestExactAlarm(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final consent = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exactAlarm),
        content: Text(l10n.exactAlarmExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
    if (consent != true) return;
    final allowed = await ref
        .read(notificationServiceProvider)
        .requestExactAlarmPermission();
    await ref.read(appSettingsProvider.notifier).setExactAlarmsAllowed(allowed);
    if (!allowed && context.mounted) {
      showAppMessage(context, l10n.exactAlarmExplanation);
    }
    final settings = ref.read(appSettingsProvider);
    if (settings.azkarRemindersEnabled) {
      await ref
          .read(notificationServiceProvider)
          .scheduleAzkarReminders(
            settings: settings.reminderSettings,
            enabled: true,
            exactAlarmsAllowed: allowed,
          );
    }
    await _reschedulePrayers(ref);
  }

  Future<void> _showNotificationDenied(
    BuildContext context,
    NotificationService service,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => NotificationPermissionScreen(service: service),
      ),
    );
  }

  Future<void> _chooseLocation(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _CitySelectionSheet(
        onSelected: (cityName, lat, lng) async {
          await ref.read(appSettingsProvider.notifier).setLocation(
                latitude: lat,
                longitude: lng,
                cityName: cityName,
              );
          await _reschedulePrayers(ref);
        },
      ),
    );
  }
}

class _CitySelectionSheet extends ConsumerStatefulWidget {
  const _CitySelectionSheet({required this.onSelected});

  final Future<void> Function(String name, double lat, double lng) onSelected;

  @override
  ConsumerState<_CitySelectionSheet> createState() => _CitySelectionSheetState();
}

class _CitySelectionSheetState extends ConsumerState<_CitySelectionSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  List<RemoteCity>? _searchedCities;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed == _query) return;
    setState(() {
      _query = trimmed;
      if (trimmed.isEmpty) {
        _searchedCities = null;
        _isLoading = false;
      } else {
        _isLoading = true;
      }
    });

    if (trimmed.isEmpty) return;

    try {
      final cities = await ref
          .read(islamicApiRepositoryProvider)
          .getCities(query: trimmed);
      if (mounted && _query == trimmed) {
        setState(() {
          _searchedCities = cities;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text(
                l10n.chooseLocation,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن أي مدينة في العالم (عبر الإنترنت)...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.teal),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.navy : AppColors.ivory,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _performSearch,
              ),
              const SizedBox(height: 10),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.teal),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      if (_searchedCities != null) ...[
                        if (_searchedCities!.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'لم يتم العثور على نتائج للمدينة المحددة',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ),
                          )
                        else
                          for (final city in _searchedCities!)
                            ListTile(
                              leading: const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.teal,
                              ),
                              title: Text(city.name),
                              subtitle: Text(
                                '${city.lat.toStringAsFixed(2)}, ${city.lng.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                await widget.onSelected(
                                  city.name,
                                  city.lat,
                                  city.lng,
                                );
                              },
                            ),
                      ] else ...[
                        ListTile(
                          leading: const Icon(Icons.my_location, color: AppColors.teal),
                          title: Text(l10n.useCurrentLocation),
                          onTap: () async {
                            Navigator.pop(context);
                            try {
                              final location = await const LocationService()
                                  .currentLocation();
                              await widget.onSelected(
                                location.cityName,
                                location.latitude,
                                location.longitude,
                              );
                            } on LocationPermissionDenied {
                              if (context.mounted) {
                                showAppMessage(context, l10n.locationPermission);
                              }
                            }
                          },
                        ),
                        const Divider(height: 1),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Text(
                            'مدن شائعة',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        for (final city in _settingsCities)
                          ListTile(
                            leading: const Icon(
                              Icons.location_city_outlined,
                              color: AppColors.gold,
                            ),
                            title: Text(city.label(l10n)),
                            onTap: () async {
                              Navigator.pop(context);
                              await widget.onSelected(
                                city.label(l10n),
                                city.latitude,
                                city.longitude,
                              );
                            },
                          ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final ReminderTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.alarm_outlined, color: AppColors.teal),
      title: Text(title),
      trailing: Text(
        TimeOfDay(hour: value.hour, minute: value.minute).format(context),
        style: const TextStyle(color: AppColors.muted),
      ),
      onTap: onTap,
    );
  }
}

class _ChoiceSetting<T> extends StatelessWidget {
  const _ChoiceSetting({
    required this.title,
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  final String title;
  final T selected;
  final List<(T, String)> options;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            children: [
              for (final (value, label) in options)
                ChoiceChip(
                  label: Text(label),
                  selected: selected == value,
                  onSelected: (_) => onSelected(value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _reschedulePrayers(WidgetRef ref) async {
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

class _SettingsCity {
  const _SettingsCity(this.key, this.latitude, this.longitude);
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

String _calculationMethodLabel(PrayerCalculationMethod method) =>
    switch (method) {
      PrayerCalculationMethod.muslimWorldLeague => 'Muslim World League',
      PrayerCalculationMethod.egyptian => 'Egyptian General Authority',
      PrayerCalculationMethod.karachi =>
        'University of Islamic Sciences, Karachi',
      PrayerCalculationMethod.ummAlQura => 'Umm al-Qura',
      PrayerCalculationMethod.dubai => 'Dubai',
      PrayerCalculationMethod.northAmerica => 'ISNA',
      PrayerCalculationMethod.kuwait => 'Kuwait',
      PrayerCalculationMethod.qatar => 'Qatar',
      PrayerCalculationMethod.singapore => 'Singapore',
      PrayerCalculationMethod.turkey => 'Turkey',
      PrayerCalculationMethod.tehran => 'Tehran',
    };

const _settingsCities = [
  _SettingsCity('riyadh', 24.7136, 46.6753),
  _SettingsCity('makkah', 21.3891, 39.8579),
  _SettingsCity('cairo', 30.0444, 31.2357),
  _SettingsCity('istanbul', 41.0082, 28.9784),
  _SettingsCity('london', 51.5072, -0.1276),
  _SettingsCity('newYork', 40.7128, -74.0060),
];
