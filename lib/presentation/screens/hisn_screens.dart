import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zikr/data/providers/islamic_api_providers.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_content.dart';

class HisnChaptersScreen extends ConsumerStatefulWidget {
  const HisnChaptersScreen({super.key});

  @override
  ConsumerState<HisnChaptersScreen> createState() => _HisnChaptersScreenState();
}

class _HisnChaptersScreenState extends ConsumerState<HisnChaptersScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chaptersAsync = ref.watch(hisnChaptersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'حصن المسلم',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث في أبواب حصن المسلم...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.teal),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppColors.navy : AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight,
                      ),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
              ),
              Expanded(
                child: chaptersAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.teal),
                  ),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 48,
                            color: AppColors.muted,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'تعذر تحميل أبواب حصن المسلم، يرجى التحقق من الاتصال بالإنترنت',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => ref.refresh(hisnChaptersProvider),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (chapters) {
                    final filtered = _searchQuery.isEmpty
                        ? chapters
                        : chapters.where((c) {
                            return c.title.contains(_searchQuery) ||
                                c.titleEn.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                );
                          }).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          'لا توجد نتائج مطابقة',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final chapter = filtered[index];
                        return Card(
                          child: ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.ocean.withAlpha(80)
                                    : AppColors.ivory,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.teal,
                                ),
                              ),
                            ),
                            title: Text(
                              chapter.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: chapter.itemsCount > 0
                                ? Text(
                                    '${chapter.itemsCount} ذكر / دعاء',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: AppColors.muted,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => HisnReaderScreen(
                                    chapterId: chapter.id,
                                    chapterTitle: chapter.title,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HisnReaderScreen extends ConsumerStatefulWidget {
  const HisnReaderScreen({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
  });

  final String chapterId;
  final String chapterTitle;

  @override
  ConsumerState<HisnReaderScreen> createState() => _HisnReaderScreenState();
}

class _HisnReaderScreenState extends ConsumerState<HisnReaderScreen> {
  final Map<int, int> _remainingCounts = {};

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(hisnChapterDetailProvider(widget.chapterId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chapterTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة ضبط التكرار',
            onPressed: () => setState(() => _remainingCounts.clear()),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: detailAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.muted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'تعذر تحميل الباب: $error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.refresh(
                        hisnChapterDetailProvider(widget.chapterId),
                      ),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ),
            data: (chapter) {
              if (chapter.items.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد أذكار في هذا الباب',
                    style: TextStyle(color: AppColors.muted),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: chapter.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = chapter.items[index];
                  final remaining = _remainingCounts[item.id] ?? item.count;
                  final isDone = remaining == 0;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            item.arabic,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 19,
                              height: 1.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (item.reference != null &&
                              item.reference!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              item.reference!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.copy_outlined,
                                      size: 20,
                                    ),
                                    color: AppColors.muted,
                                    tooltip: 'نسخ',
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: item.arabic),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('تم نسخ الذكر بنجاح'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.share_outlined,
                                      size: 20,
                                    ),
                                    color: AppColors.muted,
                                    tooltip: 'مشاركة',
                                    onPressed: () {
                                      SharePlus.instance.share(
                                        ShareParams(text: item.arabic),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: isDone
                                    ? null
                                    : () {
                                        HapticFeedback.lightImpact();
                                        setState(() {
                                          _remainingCounts[item.id] =
                                              remaining - 1;
                                        });
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDone
                                        ? AppColors.teal.withAlpha(50)
                                        : AppColors.gold,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isDone)
                                        const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: AppColors.teal,
                                        )
                                      else ...[
                                        const Text(
                                          'التكرار: ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.midnight,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '$remaining',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.midnight,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
