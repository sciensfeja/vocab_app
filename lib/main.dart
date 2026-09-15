import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Нужно для буфера обмена
import 'models/word.dart';
import 'services/file_parser.dart';
import 'screens/flashcards_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/typing_test_screen.dart';
import 'screens/ninja_game_screen.dart';

void main() => runApp(const VocabApp());

class VocabApp extends StatelessWidget {
  const VocabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocab Trainer',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<Word>>? _categories;

  // Функция вставки из буфера обмена
  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData != null && clipboardData.text != null) {
        final text = clipboardData.text!;
        if (text.trim().isEmpty) {
          _showError('Буфер обмена пуст. Сначала скопируй текст из файла.');
          return;
        }
        final parsed = FileParser.parse(text);
        if (parsed.isEmpty) {
          _showError('Не удалось распознать формат. Убедись, что текст скопирован верно.');
          return;
        }
        setState(() => _categories = parsed);
      } else {
        _showError('Не удалось прочитать буфер обмена.');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _loadTestVocabulary() {
    final testContent = '''
## О людях и отношениях
empty-nesters — родители, чьи дети выросли и уехали
retired — вышедший на пенсию
global travellers — заядлые путешественники

## Образование и работа
busker — уличный музыкант
scholarship — стипендия, грант
teacher — учитель

## Вопросительные слова
What — Что/Какой
Where — Где/Куда
How — Как
'''; // (Здесь сокращённый тестовый текст для примера)
    final parsed = FileParser.parse(testContent);
    setState(() => _categories = parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📖 Vocab Trainer')),
      body: _categories == null
          ? Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.book, size: 80, color: Colors.indigo),
              const SizedBox(height: 24),
              const Text(
                'Добро пожаловать!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Скопируй текст из своего файла со словами и нажми кнопку ниже',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),

              // ГЛАВНАЯ РАБОЧАЯ КНОПКА
              ElevatedButton.icon(
                onPressed: _pasteFromClipboard,
                icon: const Icon(Icons.paste, size: 28),
                label: const Text('Вставить из буфера обмена', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),

              const SizedBox(height: 16),
              const Text('или', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),

              // Запасная кнопка с тестовыми данными
              TextButton.icon(
                onPressed: _loadTestVocabulary,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Загрузить тестовый словарь'),
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        itemCount: _categories!.length,
        itemBuilder: (context, index) {
          final category = _categories!.keys.elementAt(index);
          final words = _categories![category]!;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.folder, color: Colors.indigo, size: 32),
              title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text('${words.length} слов'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.quiz, color: Colors.orange), tooltip: 'Тест', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(words: words)))),
                  IconButton(icon: const Icon(Icons.edit, color: Colors.green), tooltip: 'Печатный тест', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TypingTestScreen(words: words)))),
                  IconButton(icon: const Icon(Icons.play_arrow, color: Colors.indigo), tooltip: 'Карточки', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardsScreen(words: words)))),
                  IconButton(icon: const Icon(Icons.sports_martial_arts, color: Colors.purple), tooltip: 'Ниндзя', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NinjaGameScreen(words: words)))),
                ],
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardsScreen(words: words))),
            ),
          );
        },
      ),
    );
  }
}