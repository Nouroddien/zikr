class SurahSummary {
  const SurahSummary({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.ayahCount,
  });

  final int number;
  final String nameAr;
  final String nameEn;
  final int ayahCount;

  factory SurahSummary.fromJson(Map<String, dynamic> json) {
    return SurahSummary(
      number: json['number'] as int? ?? 0,
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      ayahCount: json['ayah_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'name_ar': nameAr,
        'name_en': nameEn,
        'ayah_count': ayahCount,
      };
}

class AyahModel {
  const AyahModel({
    required this.number,
    required this.textAr,
    this.textEn,
  });

  final int number;
  final String textAr;
  final String? textEn;

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      number: json['number'] as int? ?? (json['ayah'] as int? ?? 0),
      textAr: json['text_ar'] as String? ?? (json['arabic'] as String? ?? ''),
      textEn: json['text_en'] as String? ?? (json['english'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'text_ar': textAr,
        'text_en': textEn,
      };
}
