import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'data/providers/app_settings_provider.dart';
import 'data/providers/notification_service_provider.dart';
import 'l10n/app_localizations.dart';
import 'presentation/screens/main_shell.dart';

class ZikrApp extends ConsumerStatefulWidget {
  const ZikrApp({super.key});

  @override
  ConsumerState<ZikrApp> createState() => _ZikrAppState();
}

class _ZikrAppState extends ConsumerState<ZikrApp> with WidgetsBindingObserver {
  Timer? _calendarTimer;
  DateTime _observedDate = DateTime.now();
  Duration _observedTimezoneOffset = DateTime.now().timeZoneOffset;
  bool _refreshingNotifications = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _calendarTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final now = DateTime.now();
      if (now.year != _observedDate.year ||
          now.month != _observedDate.month ||
          now.day != _observedDate.day ||
          now.timeZoneOffset != _observedTimezoneOffset) {
        unawaited(_refreshNotifications());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshNotifications());
    }
  }

  Future<void> _refreshNotifications() async {
    if (_refreshingNotifications || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }
    _refreshingNotifications = true;
    final service = ref.read(notificationServiceProvider);
    try {
      await service.refreshLocalTimezone();
      await service.rescheduleEnabledNotifications(
        ref.read(appSettingsProvider),
      );
      _observedDate = DateTime.now();
      _observedTimezoneOffset = DateTime.now().timeZoneOffset;
    } finally {
      _refreshingNotifications = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _calendarTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      home: const MainShell(),
    );
  }
}
