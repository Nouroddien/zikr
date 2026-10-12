import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/remote_azkar_models.dart';

class AzkarRemoteDataSource {
  const AzkarRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<HisnChapterSummary>> getHisnChapters() async {
    final response = await _client.get(ApiEndpoints.hisnChapters);
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(HisnChapterSummary.fromJson)
          .toList();
    }
    return [];
  }

  Future<HisnChapterDetail> getHisnChapter(String chapterId) async {
    final response = await _client.get(ApiEndpoints.hisnChapter(chapterId));
    if (response is Map<String, dynamic>) {
      return HisnChapterDetail.fromJson(response);
    }
    throw StateError('Invalid chapter response format');
  }

  Future<List<RemoteZekrItem>> getMorningAzkar() async {
    return _getZekrList(ApiEndpoints.azkarMorning);
  }

  Future<List<RemoteZekrItem>> getEveningAzkar() async {
    return _getZekrList(ApiEndpoints.azkarEvening);
  }

  Future<List<RemoteZekrItem>> getSleepingAzkar() async {
    return _getZekrList(ApiEndpoints.azkarSleeping);
  }

  Future<List<RemoteZekrItem>> getPostSalahAzkar() async {
    return _getZekrList(ApiEndpoints.azkarPostSalah);
  }

  Future<List<RemoteZekrItem>> _getZekrList(String endpoint) async {
    final response = await _client.get(endpoint);
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(RemoteZekrItem.fromJson)
          .toList();
    }
    return [];
  }
}
