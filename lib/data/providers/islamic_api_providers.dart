import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../datasources/local/api_cache_datasource.dart';
import '../datasources/remote/azkar_remote_datasource.dart';
import '../datasources/remote/hadith_remote_datasource.dart';
import '../datasources/remote/prayer_remote_datasource.dart';
import '../datasources/remote/quran_remote_datasource.dart';
import '../models/remote_azkar_models.dart';
import '../models/remote_hadith_models.dart';
import '../models/remote_prayer_city.dart';
import '../models/remote_quran_models.dart';
import '../repositories/islamic_api_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(client.close);
  return client;
});

final apiCacheDataSourceProvider = Provider<ApiCacheDataSource>((ref) {
  return const ApiCacheDataSource();
});

final azkarRemoteDataSourceProvider = Provider<AzkarRemoteDataSource>((ref) {
  return AzkarRemoteDataSource(ref.watch(apiClientProvider));
});

final prayerRemoteDataSourceProvider = Provider<PrayerRemoteDataSource>((ref) {
  return PrayerRemoteDataSource(ref.watch(apiClientProvider));
});

final quranRemoteDataSourceProvider = Provider<QuranRemoteDataSource>((ref) {
  return QuranRemoteDataSource(ref.watch(apiClientProvider));
});

final hadithRemoteDataSourceProvider = Provider<HadithRemoteDataSource>((ref) {
  return HadithRemoteDataSource(ref.watch(apiClientProvider));
});

final islamicApiRepositoryProvider = Provider<IslamicApiRepository>((ref) {
  return IslamicApiRepository(
    azkarRemote: ref.watch(azkarRemoteDataSourceProvider),
    prayerRemote: ref.watch(prayerRemoteDataSourceProvider),
    quranRemote: ref.watch(quranRemoteDataSourceProvider),
    hadithRemote: ref.watch(hadithRemoteDataSourceProvider),
    cache: ref.watch(apiCacheDataSourceProvider),
  );
});

// Providers for UI Consumption
final hisnChaptersProvider =
    FutureProvider<List<HisnChapterSummary>>((ref) async {
  final repository = ref.watch(islamicApiRepositoryProvider);
  return repository.getHisnChapters();
});

final hisnChapterDetailProvider =
    FutureProvider.family<HisnChapterDetail, String>((ref, chapterId) async {
  final repository = ref.watch(islamicApiRepositoryProvider);
  return repository.getHisnChapterDetail(chapterId);
});

final remoteCitiesProvider =
    FutureProvider.family<List<RemoteCity>, String?>((ref, query) async {
  final repository = ref.watch(islamicApiRepositoryProvider);
  return repository.getCities(query: query);
});

final quranSurahsProvider =
    FutureProvider<List<SurahSummary>>((ref) async {
  final repository = ref.watch(islamicApiRepositoryProvider);
  return repository.getSurahs();
});

final randomHadithProvider =
    FutureProvider<HadithItem?>((ref) async {
  final repository = ref.watch(islamicApiRepositoryProvider);
  return repository.getRandomHadith();
});
