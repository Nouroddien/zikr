import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/remote_hadith_models.dart';

class HadithRemoteDataSource {
  const HadithRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<HadithCollection>> getCollections() async {
    final response = await _client.get(ApiEndpoints.hadithCollections);
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(HadithCollection.fromJson)
          .toList();
    }
    return [];
  }

  Future<HadithItem?> getRandomHadith([String collection = 'bukhari']) async {
    try {
      final response = await _client.get(ApiEndpoints.hadithRandom(collection));
      if (response is Map<String, dynamic>) {
        return HadithItem.fromJson(response);
      }
    } catch (_) {
      // Graceful fallback
    }
    return null;
  }

  Future<List<HadithItem>> searchHadith(
    String query, {
    String? collection,
    String lang = 'ar',
  }) async {
    final params = <String, String>{
      'q': query,
      'lang': lang,
    };
    if (collection != null) {
      params['collection'] = collection;
    }

    final response = await _client.get(
      ApiEndpoints.hadithSearch,
      queryParameters: params,
    );
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(HadithItem.fromJson)
          .toList();
    }
    return [];
  }
}
