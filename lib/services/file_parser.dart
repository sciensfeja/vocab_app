import '../models/word.dart';

class FileParser {
  /// Парсит .txt файл в стиле словаря Unit 1
  /// Возвращает: { "Категория": [Word, Word, ...], ... }
  static Map<String, List<Word>> parse(String content) {
    final Map<String, List<Word>> result = {};
    String currentCategory = 'Без категории';

    final lines = content.split('\n');

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Заголовок категории: ##  Название
      if (line.startsWith('##')) {
        currentCategory = line
            .replaceAll('##', '')
            .replaceAll(RegExp(r'[^\w\sа-яА-ЯёЁ\-]'), '')
            .trim();
        if (currentCategory.isEmpty) currentCategory = 'Без категории';
        result.putIfAbsent(currentCategory, () => []);
        continue;
      }

      // Строка со словом: "word — перевод"
      if (line.contains('—')) {
        final parts = line.split('—');
        if (parts.length >= 2) {
          final original = parts[0].trim();
          String translation = parts.sublist(1).join('—').trim();

          // Вытаскиваем подсказку из скобок
          String? hint;
          final hintMatch = RegExp(r'\(([^)]+)\)').firstMatch(translation);
          if (hintMatch != null) {
            hint = hintMatch.group(1);
            translation = translation.replaceAll(hintMatch.group(0)!, '').trim();
          }

          result.putIfAbsent(currentCategory, () => []);
          result[currentCategory]!.add(Word(
            original: original,
            translation: translation,
            category: currentCategory,
            hint: hint,
          ));
        }
      }
    }

    return result;
  }
}