import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../models/word.dart';

class TypingTestScreen extends StatefulWidget {
  final List<Word> words;
  const TypingTestScreen({super.key, required this.words});

  @override
  State<TypingTestScreen> createState() => _TypingTestScreenState();
}

class _TypingTestScreenState extends State<TypingTestScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int _currentIndex = 0;
  int _score = 0;
  int _totalQuestions = 0;
  List<Word> _shuffledWords = [];
  bool _answered = false;
  bool _isCorrect = false;
  String? _userAnswer;

  @override
  void initState() {
    super.initState();
    _startTest();
  }

  void _startTest() {
    setState(() {
      _shuffledWords = List.from(widget.words)..shuffle(Random());
      _currentIndex = 0;
      _score = 0;
      _totalQuestions = _shuffledWords.length;
      _answered = false;
      _isCorrect = false;
      _userAnswer = null;
      _controller.clear();
    });
  }

  void _checkAnswer() {
    if (_answered || _controller.text.trim().isEmpty) return;

    final currentWord = _shuffledWords[_currentIndex];
    final userAnswer = _controller.text.trim().toLowerCase();
    final correctAnswer = currentWord.translation.toLowerCase();

    // Проверяем, содержит ли ответ ключевые слова
    final isCorrect = correctAnswer.contains(userAnswer) ||
        userAnswer.contains(correctAnswer) ||
        _isSimilar(userAnswer, correctAnswer);

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
      _userAnswer = _controller.text.trim();
      if (isCorrect) {
        _score++;
      }
    });
  }

  bool _isSimilar(String a, String b) {
    // Простая проверка схожести (можно улучшить)
    final wordsA = a.split(RegExp(r'\s+'));
    final wordsB = b.split(RegExp(r'\s+'));

    int matches = 0;
    for (var word in wordsA) {
      if (wordsB.any((w) => w.contains(word) || word.contains(w))) {
        matches++;
      }
    }

    return matches >= wordsA.length ~/ 2;
  }

  void _nextQuestion() {
    if (_currentIndex < _shuffledWords.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _isCorrect = false;
        _userAnswer = null;
        _controller.clear();
      });
      _focusNode.requestFocus();
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('📝 Тест завершён!'),
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
                  ? 'Идеально! 🌟'
                  : _score > _totalQuestions * 0.7
                  ? 'Отлично! 👍'
                  : _score > _totalQuestions / 2
                  ? 'Хорошо! 💪'
                  : 'Нужно повторить! 📚',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startTest();
            },
            child: const Text('Ещё раз'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('К категориям'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
        title: Text('Печатный тест: ${currentWord.category}'),
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
                      'Напиши перевод:',
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
            // Поле ввода
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !_answered,
              decoration: InputDecoration(
                labelText: 'Твой перевод',
                border: const OutlineInputBorder(),
                filled: _answered,
                fillColor: _answered
                    ? (_isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1))
                    : null,
              ),
              onSubmitted: (_) => _checkAnswer(),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            // Кнопка проверки
            if (!_answered)
              ElevatedButton.icon(
                onPressed: _controller.text.trim().isEmpty ? null : _checkAnswer,
                icon: const Icon(Icons.check),
                label: const Text('Проверить'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            // Результат
            if (_answered) ...[
              Card(
                color: _isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _isCorrect ? '✅ Правильно!' : ' Неправильно',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                      if (!_isCorrect) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Правильный ответ:',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentWord.translation,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
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