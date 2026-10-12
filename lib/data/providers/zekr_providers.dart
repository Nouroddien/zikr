import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/zekr_repository.dart';
import '../../domain/entities/zekr.dart';

final zekrRepositoryProvider = Provider<ZekrRepository>(
  (ref) => ZekrRepository(),
);

final azkarProvider = FutureProvider<List<Zekr>>((ref) {
  return ref.watch(zekrRepositoryProvider).loadAll();
});
