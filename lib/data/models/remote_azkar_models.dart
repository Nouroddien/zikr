class HisnChapterSummary {
  const HisnChapterSummary({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.itemsCount,
  });

  final String id;
  final String title;
  final String titleEn;
  final int itemsCount;

  factory HisnChapterSummary.fromJson(Map<String, dynamic> json) {
    return HisnChapterSummary(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      itemsCount: json['items_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'title_en': titleEn,
        'items_count': itemsCount,
      };
}

class HisnItem {
  const HisnItem({
    required this.id,
    required this.arabic,
    this.english,
    this.count = 1,
    this.reference,
  });

  final int id;
  final String arabic;
  final String? english;
  final int count;
  final String? reference;

  factory HisnItem.fromJson(Map<String, dynamic> json) {
    return HisnItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      arabic: json['arabic'] as String? ?? '',
      english: json['english'] as String?,
      count: json['count'] as int? ?? 1,
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'arabic': arabic,
        'english': english,
        'count': count,
        'reference': reference,
      };
}

class HisnChapterDetail {
  const HisnChapterDetail({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.items,
  });

  final String id;
  final String title;
  final String titleEn;
  final List<HisnItem> items;

  factory HisnChapterDetail.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return HisnChapterDetail(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(HisnItem.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'title_en': titleEn,
        'items': items.map((i) => i.toJson()).toList(),
      };
}

class RemoteZekrItem {
  const RemoteZekrItem({
    required this.id,
    required this.slug,
    required this.arabic,
    this.english,
    this.count = 1,
  });

  final int id;
  final String slug;
  final String arabic;
  final String? english;
  final int count;

  factory RemoteZekrItem.fromJson(Map<String, dynamic> json) {
    return RemoteZekrItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      slug: json['slug'] as String? ?? '',
      arabic: json['arabic'] as String? ?? '',
      english: json['english'] as String?,
      count: json['count'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'arabic': arabic,
        'english': english,
        'count': count,
      };
}
