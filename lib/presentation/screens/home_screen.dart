import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_content.dart';
import '../../data/providers/app_settings_provider.dart';
import '../../data/providers/zekr_providers.dart';
import '../../data/services/prayer_times_service.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/prayer_settings.dart';
import '../../domain/entities/zekr.dart';
import '../../l10n/app_localizations.dart';
import 'main_shell.dart';
import 'screen_labels.dart';
import 'azkar_screens.dart';
import '../../data/providers/islamic_api_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({required this.onNavigate, super.key});

  final ValueChanged<int> onNavigate;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider);
    final schedule = const PrayerTimesService().calculate(
      latitude: settings.latitude,
      longitude: settings.longitude,
      dateTime: DateTime.now(),
      method: settings.calculationMethod,
      asrMethod: settings.asrMethod,
      notificationsEnabled: settings.enabledPrayers,
    );
    HijriCalendar.setLocal(settings.locale.languageCode);
    final hijri = HijriCalendar.now().toFormat('dd MMMM yyyy');
    final gregorian = DateFormat(
      'EEE, d MMM yyyy',
      settings.locale.languageCode,
    ).format(DateTime.now());

    return SafeArea(
      child: ResponsiveContent(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 18, bottom: 28),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.greeting,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              settings.locale.languageCode == 'ar'
                                  ? 'صباح مطمئن يا عُمر'
                                  : 'A peaceful morning',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '$gregorian  •  $hijri',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.favorites,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const FavoritesScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.favorite_border),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _NextPrayerCard(
                    schedule: schedule,
                    city: settings.cityName,
                    label: l10n.nextPrayer,
                    remainingLabel: l10n.remaining,
                    prayerName: prayerLabel(l10n, schedule.nextPrayer),
                  ),
                  const SizedBox(height: 24),
                  AppSectionTitle(l10n.randomZekr),
                  const SizedBox(height: 10),
                  const _RandomZekrCard(),
                  const SizedBox(height: 24),
                  AppSectionTitle(l10n.explore),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final count = constraints.maxWidth > 520 ? 3 : 2;
                      return GridView.count(
                        crossAxisCount: count,
                        childAspectRatio: 1.45,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _ExploreCard(
                            title: l10n.azkar,
                            icon: Icons.menu_book_outlined,
                            color: AppColors.gold,
                            onTap: () => widget.onNavigate(1),
                          ),
                          _ExploreCard(
                            title: l10n.sebha,
                            icon: Icons.nightlight_outlined,
                            color: AppColors.teal,
                            onTap: () => widget.onNavigate(3),
                          ),
                          _ExploreCard(
                            title: l10n.prayer,
                            icon: Icons.access_time,
                            color: AppColors.gold,
                            onTap: () => widget.onNavigate(2),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const _DailyHadithCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextPrayerCard extends StatefulWidget {
  const _NextPrayerCard({
    required this.schedule,
    required this.city,
    required this.label,
    required this.remainingLabel,
    required this.prayerName,
  });

  final PrayerSchedule schedule;
  final String city;
  final String label;
  final String remainingLabel;
  final String prayerName;

  @override
  State<_NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<_NextPrayerCard> {
  late DateTime _now;
  late DateTime _startedAt;
  late Duration _interval;
  late final Stream<DateTime> _ticks;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _updateInterval();
    _ticks = Stream<DateTime>.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  void didUpdateWidget(covariant _NextPrayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schedule.nextPrayerTime != widget.schedule.nextPrayerTime) {
      _updateInterval();
    }
  }

  void _updateInterval() {
    _startedAt =
        widget.schedule.entries
            .where(
              (entry) => entry.time.isBefore(widget.schedule.nextPrayerTime),
            )
            .lastOrNull
            ?.time ??
        DateTime.now();
    _interval = widget.schedule.nextPrayerTime.difference(_startedAt);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _ticks,
      initialData: _now,
      builder: (context, snapshot) {
        _now = snapshot.data ?? DateTime.now();
        final remaining = widget.schedule.nextPrayerTime.difference(_now);
        final fraction = _interval.inSeconds <= 0
            ? 0.0
            : (1 - remaining.inSeconds / _interval.inSeconds)
                  .clamp(0.0, 1.0)
                  .toDouble();
        final time = remaining.isNegative ? Duration.zero : remaining;
        final hours = time.inHours.toString().padLeft(2, '0');
        final minutes = time.inMinutes.remainder(60).toString().padLeft(2, '0');
        final seconds = time.inSeconds.remainder(60).toString().padLeft(2, '0');

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.navy, AppColors.ocean],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 94,
                height: 94,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: fraction,
                      strokeWidth: 5,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.remainingLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                          ),
                        ),
                        Text(
                          '$hours:$minutes:$seconds',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.prayerName,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 23,
                      ),
                    ),
                    Text(
                      '${DateFormat.jm().format(widget.schedule.nextPrayerTime)}  •  ${widget.city}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RandomZekrCard extends ConsumerStatefulWidget {
  const _RandomZekrCard();

  @override
  ConsumerState<_RandomZekrCard> createState() => _RandomZekrCardState();
}

class _RandomZekrCardState extends ConsumerState<_RandomZekrCard> {
  Zekr? _selected;
  bool _saved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selected == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chooseZekr();
      });
    }
  }

  Future<void> _chooseZekr({bool forceNew = false}) async {
    final data = await ref.read(azkarProvider.future);
    if (!mounted || data.isEmpty) return;
    final preferences = await SharedPreferences.getInstance();
    final settings = ref.read(appSettingsProvider);
    final lastId = preferences.getString('lastRandomZekrId');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final previousDate = preferences.getString('lastRandomZekrDate');
    Zekr? selected;
    if (!forceNew &&
        settings.randomZekrFrequency == RandomZekrFrequency.daily &&
        previousDate == today &&
        lastId != null) {
      selected = data.where((zekr) => zekr.id == lastId).firstOrNull;
    }
    if (selected == null) {
      final candidates = data.where((zekr) => zekr.id != lastId).toList();
      final pool = candidates.isEmpty ? data : candidates;
      selected = pool[Random.secure().nextInt(pool.length)];
    }
    await preferences.setString('lastRandomZekrId', selected.id);
    await preferences.setString('lastRandomZekrDate', today);
    final favorites = preferences.getStringList('favoriteZekrIds') ?? [];
    if (!mounted) return;
    setState(() {
      _selected = selected;
      _saved = favorites.contains(selected!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selection = ref.watch(azkarProvider);
    if (selection.isLoading) {
      return const Card(
        child: SizedBox(
          height: 190,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (selection.hasError) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Unable to load azkar: ${selection.error}'),
        ),
      );
    }
    final zekr = _selected ?? selection.value!.first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: IconButton(
                tooltip: l10n.favorites,
                onPressed: () => _toggleFavorite(zekr),
                icon: Icon(
                  _saved ? Icons.favorite : Icons.favorite_border,
                  color: _saved ? AppColors.gold : AppColors.muted,
                ),
              ),
            ),
            Text(
              zekr.arabic,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 25,
                height: 1.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (Localizations.localeOf(context).languageCode == 'en') ...[
              const SizedBox(height: 8),
              Text(
                zekr.translation,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              '${l10n.repeat}: ${zekr.repeatCount}',
              style: const TextStyle(
                color: AppColors.teal,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => _chooseZekr(forceNew: true),
                  icon: const Icon(Icons.sync),
                  label: Text(l10n.newZekr),
                ),
                IconButton(
                  tooltip: l10n.copy,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: zekr.arabic));
                    showAppMessage(context, l10n.copy);
                  },
                  icon: const Icon(Icons.copy_outlined),
                ),
                IconButton(
                  tooltip: l10n.share,
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(text: '${zekr.arabic}\n\n${zekr.translation}'),
                  ),
                  icon: const Icon(Icons.share_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(Zekr zekr) async {
    final preferences = await SharedPreferences.getInstance();
    final favorites = preferences.getStringList('favoriteZekrIds') ?? [];
    final wasSaved = favorites.contains(zekr.id);
    if (wasSaved) {
      favorites.remove(zekr.id);
    } else {
      favorites.add(zekr.id);
    }
    await preferences.setStringList('favoriteZekrIds', favorites);
    if (!mounted) return;
    setState(() => _saved = !wasSaved);
    showAppMessage(context, AppLocalizations.of(context)!.saved);
  }
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 26),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyHadithCard extends ConsumerWidget {
  const _DailyHadithCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hadithAsync = ref.watch(randomHadithProvider);

    return hadithAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (hadith) {
        if (hadith == null || hadith.arab.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppSectionTitle('حديث نبوي شريف'),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      hadith.arab,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'صحيح البخاري',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy_outlined, size: 18),
                              color: AppColors.muted,
                              tooltip: 'نسخ',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: hadith.arab));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم نسخ الحديث بنجاح'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.share_outlined, size: 18),
                              color: AppColors.muted,
                              tooltip: 'مشاركة',
                              onPressed: () => SharePlus.instance.share(
                                ShareParams(text: hadith.arab),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
