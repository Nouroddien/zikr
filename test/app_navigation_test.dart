import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zikr/app.dart';
import 'package:zikr/data/providers/app_settings_provider.dart';
import 'package:zikr/data/providers/zekr_providers.dart';
import 'package:zikr/domain/entities/zekr.dart';

void main() {
  testWidgets('bottom navigation opens all five feature screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
                category: 'morning',
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
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('السلام عليكم'), findsOneWidget);
    await _tapDestination(tester, 'الأذكار');
    expect(find.text('الصباح'), findsWidgets);

    await _tapDestination(tester, 'الصلاة');
    expect(find.text('الشروق'), findsOneWidget);

    await _tapDestination(tester, 'السبحة');
    expect(find.text('سُبْحَانَ اللَّهِ'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _tapDestination(tester, 'الإعدادات');
    expect(find.text('المظهر'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _tapDestination(tester, 'الرئيسية');
    await tester.tap(find.text('السبحة').first);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('السبحة'), findsWidgets);
  });
}

Future<void> _tapDestination(WidgetTester tester, String label) async {
  final destination = find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );
  await tester.tap(destination);
  await tester.pump(const Duration(milliseconds: 350));
}
