abstract final class ApiEndpoints {
  static const String baseUrl = 'https://islamic-api.fly.dev';

  // Azkar
  static const String azkarMorning = '/v1/azkar/morning';
  static const String azkarEvening = '/v1/azkar/evening';
  static const String azkarSleeping = '/v1/azkar/sleeping';
  static const String azkarPostSalah = '/v1/azkar/post-salah';
  static const String hisnChapters = '/v1/azkar/hisn/chapters';
  static String hisnChapter(String chapterId) => '/v1/azkar/hisn/$chapterId';

  // Prayer
  static const String prayerCities = '/v1/prayer/cities';
  static const String prayerTimes = '/v1/prayer/times';

  // Quran
  static const String quranSurahs = '/v1/quran/surahs';
  static String quranSurah(int surahId) => '/v1/quran/surah/$surahId';
  static String quranAyah(int surahId, int ayahId) =>
      '/v1/quran/ayah/$surahId/$ayahId';
  static const String quranSearch = '/v1/quran/search';

  // Hadith
  static const String hadithCollections = '/v1/hadith/collections';
  static String hadithRandom(String collection) =>
      '/v1/hadith/random/$collection';
  static const String hadithSearch = '/v1/hadith/search';

  // Duas
  static const String duasCategories = '/v1/duas/categories';
  static String duasCategory(String category) => '/v1/duas/$category';
}
