import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_content.dart';
import '../../data/providers/app_settings_provider.dart';
import '../../data/providers/zekr_providers.dart';
import '../../domain/entities/zekr.dart';
import '../../l10n/app_localizations.dart';
import 'main_shell.dart';
import 'screen_labels.dart';

const _categoryOrder = [
  'morning',
  'evening',
  'after_prayer',
  'sleep',
  'waking',
  'general',
];

const _categoryIcons = {
  'morning': Icons.wb_sunny_outlined,
  'evening': Icons.nightlight_outlined,
  'after_prayer': Icons.auto_awesome_outlined,
  'sleep': Icons.bedtime_outlined,
  'waking': Icons.wb_twilight_outlined,
  'general': Icons.favorite_border,
};

class AzkarCategoriesScreen extends ConsumerWidget {
  const AzkarCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final azkar = ref.watch(azkarProvider);
    return SafeArea(
      child: ResponsiveContent(
        child: azkar.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Unable to load azkar: $error')),
          data: (entries) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 20, bottom: 24),
                  sliver: SliverList.list(
                    children: [
                      Text(
                        l10n.azkar,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.dailyProgress,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 16),
                      _DailyProgressCard(entries: entries),
                      const SizedBox(height: 20),
                      GridView.count(
                        crossAxisCount: MediaQuery.sizeOf(context).width > 600
                            ? 3
                            : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.12,
                        children: [
                          for (final category in _categoryOrder)
                            _AzkarCategoryCard(
                              category: category,
                              entries: entries
                                  .where((zekr) => zekr.category == category)
                                  .toList(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.favorite_border,
                            color: AppColors.gold,
                          ),
                          title: Text(l10n.favorites),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const FavoritesScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DailyProgressCard extends ConsumerWidget {
  const _DailyProgressCard({required this.entries});

  final List<Zekr> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final preferences = ref.watch(sharedPreferencesProvider);
    final today = DateTime.now();
    final key = 'completed_${today.year}-${today.month}-${today.day}';
    final completed = preferences.getStringList(key) ?? [];
    final progress = entries.isEmpty ? 0.0 : completed.length / entries.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.gold),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dailyProgress,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${completed.length} / ${entries.length} ${l10n.completed}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    color: AppColors.teal,
                    backgroundColor: AppColors.teal.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AzkarCategoryCard extends StatelessWidget {
  const _AzkarCategoryCard({required this.category, required this.entries});

  final String category;
  final List<Zekr> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                AzkarListScreen(category: category, entries: entries),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.teal.withValues(alpha: 0.12),
                foregroundColor: category == 'evening'
                    ? AppColors.teal
                    : AppColors.gold,
                child: Icon(_categoryIcons[category]),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    categoryLabel(l10n, category),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${entries.length} ${l10n.azkar}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Icon(
                  Icons.chevron_left,
                  size: 18,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AzkarListScreen extends StatelessWidget {
  const AzkarListScreen({
    required this.category,
    required this.entries,
    super.key,
  });

  final String category;
  final List<Zekr> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(categoryLabel(l10n, category))),
      body: ResponsiveContent(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: entries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final zekr = entries[index];
            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ZekrReaderScreen(zekr: zekr),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        zekr.arabic,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 21, height: 1.7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.repeat}: ${zekr.repeatCount}',
                        style: const TextStyle(color: AppColors.teal),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ZekrReaderScreen extends StatefulWidget {
  const ZekrReaderScreen({required this.zekr, super.key});

  final Zekr zekr;

  @override
  State<ZekrReaderScreen> createState() => _ZekrReaderScreenState();
}

class _ZekrReaderScreenState extends State<ZekrReaderScreen> {
  int _count = 0;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((preferences) {
      if (mounted) {
        setState(
          () => _saved =
              preferences
                  .getStringList('favoriteZekrIds')
                  ?.contains(widget.zekr.id) ??
              false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final target = widget.zekr.repeatCount;
    final done = _count >= target;
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryLabel(l10n, widget.zekr.category)),
        actions: [
          IconButton(
            tooltip: l10n.favorites,
            onPressed: _toggleFavorite,
            icon: Icon(
              _saved ? Icons.favorite : Icons.favorite_border,
              color: _saved ? AppColors.gold : null,
            ),
          ),
          IconButton(
            tooltip: l10n.share,
            onPressed: () => SharePlus.instance.share(
              ShareParams(
                text: '${widget.zekr.arabic}\n\n${widget.zekr.translation}',
              ),
            ),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ResponsiveContent(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        Text(
                          widget.zekr.arabic,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 28,
                            height: 1.9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.zekr.translation,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 15,
                          ),
                        ),
                        if (widget.zekr.benefit case final benefit?) ...[
                          const SizedBox(height: 12),
                          Text(
                            benefit,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.teal),
                          ),
                        ],
                        const Divider(height: 30),
                        Text(
                          widget.zekr.source,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  l10n.progress,
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 230,
                  height: 230,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: target == 0 ? 0 : _count / target,
                        strokeWidth: 8,
                        backgroundColor: AppColors.teal.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.gold,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_count',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text('${l10n.repeat}: $target'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  done ? l10n.done : l10n.tapToCount,
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: done ? null : _increment,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(160, 54),
                  ),
                  child: Text(done ? l10n.done : l10n.tapToCount),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _count = 0),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.reset),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _increment() async {
    if (_count >= widget.zekr.repeatCount) return;
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    setState(() => _count++);
    if (_count == widget.zekr.repeatCount) {
      final preferences = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final key = 'completed_${now.year}-${now.month}-${now.day}';
      final completed = preferences.getStringList(key) ?? [];
      if (!completed.contains(widget.zekr.id)) {
        completed.add(widget.zekr.id);
        await preferences.setStringList(key, completed);
      }
      if (mounted) showAppMessage(context, AppLocalizations.of(context)!.done);
    }
  }

  Future<void> _toggleFavorite() async {
    final preferences = await SharedPreferences.getInstance();
    final favorites = preferences.getStringList('favoriteZekrIds') ?? [];
    if (_saved) {
      favorites.remove(widget.zekr.id);
    } else {
      favorites.add(widget.zekr.id);
    }
    await preferences.setStringList('favoriteZekrIds', favorites);
    if (mounted) setState(() => _saved = !_saved);
  }
}

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favorites =
        ref.watch(sharedPreferencesProvider).getStringList('favoriteZekrIds') ??
        [];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.favorites)),
      body: ResponsiveContent(
        child: ref
            .watch(azkarProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Unable to load favorites: $error')),
              data: (entries) {
                final selected = entries
                    .where((zekr) => favorites.contains(zekr.id))
                    .toList();
                if (selected.isEmpty) {
                  return Center(child: Text(l10n.emptyFavorites));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: selected.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final zekr = selected[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          zekr.arabic,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(categoryLabel(l10n, zekr.category)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ZekrReaderScreen(zekr: zekr),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      ),
    );
  }
}
