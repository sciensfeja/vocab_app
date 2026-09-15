import 'package:flutter/material.dart';
import 'dart:math';
import '../models/word.dart';

class QuizScreen extends StatefulWidget {
  final List<Word> words;
  const QuizScreen({super.key, required this.words});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int _totalQuestions = 0;
  List<Word> _shuffledWords = [];
  List<String> _options = [];
  bool _answered = false;
  int? _selectedOption;
  String? _correctAnswer;

  @override
  void initState() {
    super.initState();
    _startQuiz();
  }

  void _startQuiz() {
    setState(() {
      _shuffledWords = List.from(widget.words)..shuffle(Random());
      _currentIndex = 0;
      _score = 0;
      _totalQuestions = _shuffledWords.length;
      _generateOptions();
      _answered = false;
      _selectedOption = null;
    });
  }

  void _generateOptions() {
    if (_shuffledWords.isEmpty) return;

    final currentWord = _shuffledWords[_currentIndex];
    final correctAnswer = currentWord.translation;

    // Берём 3 неправильных ответа из других слов
    final otherWords = widget.words
        .where((w) => w.translation != correctAnswer)
        .map((w) => w.translation)
        .toList()
      ..shuffle(Random());

    final wrongAnswers = otherWords.take(3).toList();

    // Смешиваем правильный и неправильные
    _options = [correctAnswer, ...wrongAnswers]..shuffle(Random());
    _correctAnswer = correctAnswer;
  }

  void _checkAnswer(int selectedIndex) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedOption = selectedIndex;
      if (_options[selectedIndex] == _correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _shuffledWords.length - 1) {
      setState(() {
        _currentIndex++;
        _generateOptions();
        _answered = false;
        _selectedOption = null;
      });
    } else {
      // Показываем результат
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Тест завершён!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Правильных ответов: $_score из $_totalQuestions',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _score == _totalQuestions
                  ? 'Отлично! 🌟'
                  : _score > _totalQuestions / 2
                  ? 'Хорошо! 👍'
                  : 'Нужно повторить! ',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startQuiz();
            },
            child: const Text('Пройти ещё раз'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Вернуться к категориям'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_shuffledWords.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentWord = _shuffledWords[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Тест: ${currentWord.category}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/$_totalQuestions | 💯 $_score',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Карточка с вопросом
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Text(
                      'Как переводится?',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentWord.original,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (currentWord.hint != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '(${currentWord.hint})',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Варианты ответов
            ...List.generate(4, (index) {
              final isSelected = _selectedOption == index;
              final isCorrect = _options[index] == _correctAnswer;
              final showCorrect = _answered && isCorrect;
              final showWrong = _answered && isSelected && !isCorrect;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: _answered ? null : () => _checkAnswer(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showCorrect
                        ? Colors.green
                        : showWrong
                        ? Colors.red
                        : null,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _options[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }),
            if (_answered) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _nextQuestion,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Дальше'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}