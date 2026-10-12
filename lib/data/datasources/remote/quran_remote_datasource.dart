import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/remote_quran_models.dart';

class QuranRemoteDataSource {
  const QuranRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<SurahSummary>> getSurahs() async {
    final response = await _client.get(ApiEndpoints.quranSurahs);
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(SurahSummary.fromJson)
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getSurah(int surahId) async {
    final response = await _client.get(ApiEndpoints.quranSurah(surahId));
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw StateError('Invalid surah response');
  }

  Future<List<dynamic>> searchQuran(String query) async {
    final response = await _client.get(
      ApiEndpoints.quranSearch,
      queryParameters: {'q': query},
    );
    if (response is List) {
      return response;
    }
    return [];
  }
}
