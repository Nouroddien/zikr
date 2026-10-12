import 'package:flutter_test/flutter_test.dart';
import 'package:zikr/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zikr/core/theme/app_theme.dart';
import 'package:zikr/core/widgets/responsive_content.dart';
import 'package:zikr/data/providers/app_settings_provider.dart';
import 'package:zikr/data/providers/zekr_providers.dart';
import 'package:zikr/data/repositories/zekr_repository.dart';
import 'package:zikr/domain/entities/zekr.dart';

void main() {
  testWidgets('app starts with Arabic localization', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          azkarProvider.overrideWith(
            (ref) async => [
              const Zekr(
                id: 'test',
                category: 'general',
                arabic: 'ذِكْر',
                translation: 'A remembrance',
                repeatCount: 1,
                source: 'Test fixture',
              ),
            ],
          ),
        ],
        child: const ZikrApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('السلام عليكم'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('السلام عليكم'))),
      TextDirection.rtl,
    );
  });

  testWidgets('responsive content is constrained on wide screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResponsiveContent(
            child: SizedBox(
              key: const Key('responsive-child'),
              width: double.infinity,
              height: 100,
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('responsive-child'))).width,
      680,
    );
  });

  test('design system provides light and dark themes', () {
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });

  test('bundled azkar data has ten valid entries in every category', () async {
    final azkar = await ZekrRepository().loadAll();
    final counts = <String, int>{};
    for (final zekr in azkar) {
      counts.update(zekr.category, (count) => count + 1, ifAbsent: () => 1);
    }

    expect(azkar, hasLength(62));
    expect(counts.keys, hasLength(6));
    for (final category in [
      'morning',
      'evening',
      'after_prayer',
      'sleep',
      'waking',
      'general',
    ]) {
      expect(
        counts[category],
        greaterThanOrEqualTo(10),
        reason: '$category starter dataset',
      );
    }
    expect(azkar.every((zekr) => zekr.repeatCount > 0), isTrue);
  });
}
