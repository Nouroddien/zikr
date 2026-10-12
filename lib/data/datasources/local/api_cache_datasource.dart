import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiCacheDataSource {
  const ApiCacheDataSource();

  static const String _prefix = 'api_cache_';

  Future<void> cacheJson(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode({
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'payload': data,
    });
    await prefs.setString('$_prefix$key', encoded);
  }

  Future<dynamic> getCachedJson(String key, {Duration? maxAge}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$key');
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (maxAge != null) {
        final timestamp = decoded['timestamp'] as int?;
        if (timestamp != null) {
          final cachedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
          if (DateTime.now().difference(cachedDate) > maxAge) {
            return null; // Expired
          }
        }
      }
      return decoded['payload'];
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
  }
}
