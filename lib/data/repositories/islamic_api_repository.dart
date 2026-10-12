import '../datasources/local/api_cache_datasource.dart';
import '../datasources/remote/azkar_remote_datasource.dart';
import '../datasources/remote/hadith_remote_datasource.dart';
import '../datasources/remote/prayer_remote_datasource.dart';
import '../datasources/remote/quran_remote_datasource.dart';
import '../models/remote_azkar_models.dart';
import '../models/remote_hadith_models.dart';
import '../models/remote_prayer_city.dart';
import '../models/remote_quran_models.dart';

class IslamicApiRepository {
  IslamicApiRepository({
    required this.azkarRemote,
    required this.prayerRemote,
    required this.quranRemote,
    required this.hadithRemote,
    this.cache = const ApiCacheDataSource(),
  });

  final AzkarRemoteDataSource azkarRemote;
  final PrayerRemoteDataSource prayerRemote;
  final QuranRemoteDataSource quranRemote;
  final HadithRemoteDataSource hadithRemote;
  final ApiCacheDataSource cache;

  static const String _hisnChaptersCacheKey = 'hisn_chapters_list';
  static const String _citiesCacheKey = 'prayer_cities_list';
  static const String _quranSurahsCacheKey = 'quran_surahs_list';

  // --- HISN AL-MUSLIM (Azkar) ---

  Future<List<HisnChapterSummary>> getHisnChapters({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await cache.getCachedJson(
        _hisnChaptersCacheKey,
        maxAge: const Duration(days: 7),
      );
      if (cached is List) {
        return cached
            .whereType<Map<String, dynamic>>()
            .map(HisnChapterSummary.fromJson)
            .toList();
      }
    }

    try {
      final remoteChapters = await azkarRemote.getHisnChapters();
      if (remoteChapters.isNotEmpty) {
        await cache.cacheJson(
          _hisnChaptersCacheKey,
          remoteChapters.map((c) => c.toJson()).toList(),
        );
      }
      return remoteChapters;
    } catch (_) {
      // Offline fallback to cache even if older than maxAge
      final stale = await cache.getCachedJson(_hisnChaptersCacheKey);
      if (stale is List) {
        return stale
            .whereType<Map<String, dynamic>>()
            .map(HisnChapterSummary.fromJson)
            .toList();
      }
      rethrow;
    }
  }

  Future<HisnChapterDetail> getHisnChapterDetail(
    String chapterId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'hisn_chapter_$chapterId';
    if (!forceRefresh) {
      final cached = await cache.getCachedJson(cacheKey);
      if (cached is Map<String, dynamic>) {
        return HisnChapterDetail.fromJson(cached);
      }
    }

    try {
      final detail = await azkarRemote.getHisnChapter(chapterId);
      await cache.cacheJson(cacheKey, detail.toJson());
      return detail;
    } catch (_) {
      final stale = await cache.getCachedJson(cacheKey);
      if (stale is Map<String, dynamic>) {
        return HisnChapterDetail.fromJson(stale);
      }
      rethrow;
    }
  }

  // --- PRAYER CITIES ---

  Future<List<RemoteCity>> getCities({
    String? query,
    bool forceRefresh = false,
  }) async {
    if (query == null || query.isEmpty) {
      if (!forceRefresh) {
        final cached = await cache.getCachedJson(
          _citiesCacheKey,
          maxAge: const Duration(days: 14),
        );
        if (cached is List) {
          return cached
              .whereType<Map<String, dynamic>>()
              .map(RemoteCity.fromJson)
              .toList();
        }
      }
    }

    try {
      final cities = await prayerRemote.getCities(query: query);
      if ((query == null || query.isEmpty) && cities.isNotEmpty) {
        await cache.cacheJson(
          _citiesCacheKey,
          cities.map((c) => c.toJson()).toList(),
        );
      }
      return cities;
    } catch (_) {
      final stale = await cache.getCachedJson(_citiesCacheKey);
      if (stale is List) {
        final all = stale
            .whereType<Map<String, dynamic>>()
            .map(RemoteCity.fromJson)
            .toList();
        if (query != null && query.isNotEmpty) {
          return all
              .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
        return all;
      }
      return [];
    }
  }

  // --- QURAN ---

  Future<List<SurahSummary>> getSurahs({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await cache.getCachedJson(
        _quranSurahsCacheKey,
        maxAge: const Duration(days: 30),
      );
      if (cached is List) {
        return cached
            .whereType<Map<String, dynamic>>()
            .map(SurahSummary.fromJson)
            .toList();
      }
    }

    try {
      final surahs = await quranRemote.getSurahs();
      if (surahs.isNotEmpty) {
        await cache.cacheJson(
          _quranSurahsCacheKey,
          surahs.map((s) => s.toJson()).toList(),
        );
      }
      return surahs;
    } catch (_) {
      final stale = await cache.getCachedJson(_quranSurahsCacheKey);
      if (stale is List) {
        return stale
            .whereType<Map<String, dynamic>>()
            .map(SurahSummary.fromJson)
            .toList();
      }
      rethrow;
    }
  }

  // --- HADITH ---

  Future<HadithItem?> getRandomHadith([String collection = 'bukhari']) {
    return hadithRemote.getRandomHadith(collection);
  }

  Future<List<HadithCollection>> getHadithCollections() {
    return hadithRemote.getCollections();
  }
}
