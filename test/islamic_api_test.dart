import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:zikr/core/network/api_client.dart';
import 'package:zikr/core/network/api_endpoints.dart';
import 'package:zikr/data/datasources/remote/azkar_remote_datasource.dart';
import 'package:zikr/data/datasources/remote/hadith_remote_datasource.dart';
import 'package:zikr/data/datasources/remote/prayer_remote_datasource.dart';
import 'package:zikr/data/datasources/remote/quran_remote_datasource.dart';
import 'package:zikr/data/repositories/islamic_api_repository.dart';

void main() {
  group('IslamicApiClient & Repositories Tests', () {
    test('fetches Hisn chapters list correctly', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == ApiEndpoints.hisnChapters) {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': '1',
                  'title': 'أذكار الاستيقاظ من النوم',
                  'title_en': 'Words of remembrance upon waking up',
                  'items_count': 4,
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(httpClient: mockClient);
      final azkarRemote = AzkarRemoteDataSource(apiClient);
      final chapters = await azkarRemote.getHisnChapters();

      expect(chapters.length, 1);
      expect(chapters.first.id, '1');
      expect(chapters.first.title, 'أذكار الاستيقاظ من النوم');
      expect(chapters.first.itemsCount, 4);
    });

    test('fetches Hisn chapter detail correctly', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/v1/azkar/hisn/1') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': '1',
                'title': 'أذكار الاستيقاظ',
                'title_en': 'Waking up',
                'items': [
                  {
                    'id': 1,
                    'arabic': 'الحمد لله الذي أحيانا بعد ما أماتنا وإليه النشور',
                    'count': 1,
                  },
                ],
              },
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(httpClient: mockClient);
      final azkarRemote = AzkarRemoteDataSource(apiClient);
      final detail = await azkarRemote.getHisnChapter('1');

      expect(detail.id, '1');
      expect(detail.items.length, 1);
      expect(detail.items.first.arabic, contains('الحمد لله الذي أحيانا'));
    });

    test('fetches remote cities list correctly', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == ApiEndpoints.prayerCities) {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {'name': 'Cairo', 'lat': 30.0444, 'lng': 31.2357},
                {'name': 'Riyadh', 'lat': 24.7136, 'lng': 46.6753},
              ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(httpClient: mockClient);
      final prayerRemote = PrayerRemoteDataSource(apiClient);
      final cities = await prayerRemote.getCities();

      expect(cities.length, 2);
      expect(cities.first.name, 'Cairo');
      expect(cities.last.name, 'Riyadh');
    });

    test('fetches random hadith correctly', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == ApiEndpoints.hadithRandom('bukhari')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': 1,
                'arab': 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
                'text': 'Actions are according to intentions.',
              },
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(httpClient: mockClient);
      final hadithRemote = HadithRemoteDataSource(apiClient);
      final hadith = await hadithRemote.getRandomHadith('bukhari');

      expect(hadith, isNotNull);
      expect(hadith!.arab, 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ');
    });
  });
}
