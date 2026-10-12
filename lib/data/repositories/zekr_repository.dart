import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/zekr.dart';

class ZekrRepository {
  ZekrRepository({AssetBundle? assetBundle})
    : assetBundle = assetBundle ?? rootBundle;

  final AssetBundle assetBundle;

  Future<List<Zekr>> loadAll() async {
    final source = await assetBundle.loadString('assets/data/azkar.json');
    final decoded = jsonDecode(source);
    if (decoded is! List<Object?>) {
      throw const FormatException('Azkar data must be a JSON list');
    }
    final azkar = decoded
        .map((item) {
          if (item is! Map<String, Object?>) {
            throw const FormatException(
              'Each zekr entry must be a JSON object',
            );
          }
          return Zekr.fromJson(item);
        })
        .toList(growable: false);

    final ids = azkar.map((zekr) => zekr.id).toSet();
    if (ids.length != azkar.length) {
      throw const FormatException('Azkar data contains duplicate IDs');
    }
    return azkar;
  }
}
