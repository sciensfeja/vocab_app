class Word {
  final String original;
  final String translation;
  final String category;
  final String? hint;

  Word({
    required this.original,
    required this.translation,
    required this.category,
    this.hint,
  });

  @override
  String toString() => '$original — $translation';
}