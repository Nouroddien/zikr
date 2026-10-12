class Zekr {
  const Zekr({
    required this.id,
    required this.category,
    required this.arabic,
    required this.translation,
    required this.repeatCount,
    required this.source,
    this.benefit,
  });

  final String id;
  final String category;
  final String arabic;
  final String translation;
  final int repeatCount;
  final String source;
  final String? benefit;

  factory Zekr.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final category = json['category'];
    final arabic = json['arabic'];
    final translation = json['translation'];
    final repeatCount = json['repeat_count'];
    final source = json['source'];
    final benefit = json['benefit'];

    if (id is! String ||
        category is! String ||
        arabic is! String ||
        translation is! String ||
        repeatCount is! int ||
        repeatCount < 1 ||
        source is! String ||
        (benefit != null && benefit is! String)) {
      throw const FormatException('Invalid zekr data');
    }

    return Zekr(
      id: id,
      category: category,
      arabic: arabic,
      translation: translation,
      repeatCount: repeatCount,
      source: source,
      benefit: benefit as String?,
    );
  }
}
