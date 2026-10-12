import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/remote_prayer_city.dart';

class PrayerRemoteDataSource {
  const PrayerRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<RemoteCity>> getCities({String? query}) async {
    final params = <String, String>{};
    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }
    final response = await _client.get(
      ApiEndpoints.prayerCities,
      queryParameters: params.isNotEmpty ? params : null,
    );

    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(RemoteCity.fromJson)
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>?> getPrayerTimes({
    String? city,
    double? lat,
    double? lon,
  }) async {
    final params = <String, String>{};
    if (city != null) params['city'] = city;
    if (lat != null) params['lat'] = lat.toString();
    if (lon != null) params['lon'] = lon.toString();

    final response = await _client.get(
      ApiEndpoints.prayerTimes,
      queryParameters: params,
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }
}
