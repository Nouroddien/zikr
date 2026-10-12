import 'dart:async' as dart_async;
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    this.baseUrl = ApiEndpoints.baseUrl,
    this.timeout = const Duration(seconds: 12),
  }) : _client = httpClient ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParameters,
    );

    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'ZikrApp/1.0',
              ...?headers,
            },
          )
          .timeout(timeout);

      final decoded = _handleResponse(response);
      return decoded;
    } on SocketException catch (e) {
      throw NetworkException('No internet connection or host unreachable', cause: e);
    } on dart_async.TimeoutException catch (e) {
      throw TimeoutException('Request to $endpoint timed out: ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException('HTTP error occurred', cause: e);
    } on FormatException catch (e) {
      throw ApiException('Failed to parse response JSON', cause: e);
    }
  }

  dynamic _handleResponse(http.Response response) {
    final bodyString = utf8.decode(response.bodyBytes);
    final decoded = jsonDecode(bodyString);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        return decoded['data'];
      }
      return decoded;
    }

    final errorMessage = (decoded is Map<String, dynamic> && decoded['detail'] != null)
        ? decoded['detail'].toString()
        : 'Request failed with status code: ${response.statusCode}';

    throw ServerException(errorMessage, statusCode: response.statusCode);
  }

  void close() {
    _client.close();
  }
}
