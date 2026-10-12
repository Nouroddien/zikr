class HadithCollection {
  const HadithCollection({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.totalHadith,
    this.sectionsCount = 0,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final int totalHadith;
  final int sectionsCount;

  factory HadithCollection.fromJson(Map<String, dynamic> json) {
    return HadithCollection(
      id: json['id'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      totalHadith: json['total_hadith'] as int? ?? 0,
      sectionsCount: json['sections_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_ar': nameAr,
        'name_en': nameEn,
        'total_hadith': totalHadith,
        'sections_count': sectionsCount,
      };
}

class HadithItem {
  const HadithItem({
    required this.id,
    required this.arab,
    this.text,
    this.reference,
  });

  final int id;
  final String arab;
  final String? text;
  final String? reference;

  factory HadithItem.fromJson(Map<String, dynamic> json) {
    return HadithItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      arab: json['arab'] as String? ?? (json['arabic'] as String? ?? ''),
      text: json['text'] as String? ?? (json['english'] as String?),
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'arab': arab,
        'text': text,
        'reference': reference,
      };
}
