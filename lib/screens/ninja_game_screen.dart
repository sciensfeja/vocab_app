import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../models/word.dart';

class NinjaGameScreen extends StatefulWidget {
  final List<Word> words;
  const NinjaGameScreen({super.key, required this.words});

  @override
  State<NinjaGameScreen> createState() => _NinjaGameScreenState();
}

class _NinjaGameScreenState extends State<NinjaGameScreen> {
  List<_FloatingWord> _floatingWords = [];
  int _score = 0;
  int _lives = 3;
  bool _gameOver = false;
  Word? _targetWord;

  Timer? _gameLoop;
  Timer? _spawnTimer;
  final Random _random = Random();

  final List<Color> _colors = [
    Colors.redAccent, Colors.blueAccent, Colors.greenAccent,
    Colors.orangeAccent, Colors.purpleAccent, Colors.pinkAccent,
    Colors.tealAccent, Colors.amberAccent,
  ];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    // Отменяем старые таймеры, если были
    _gameLoop?.cancel();
    _spawnTimer?.cancel();

    setState(() {
      _floatingWords.clear();
      _score = 0;
      _lives = 3;
      _gameOver = false;
    });

    _generateTargetWord();

    // Игровой цикл: обновляет позиции слов 30 раз в секунду
    _gameLoop = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_gameOver) return;
      _updatePositions();
    });

    // Спавн новых слов каждые 1.2 секунды
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (_gameOver) return;
      _spawnWord();
    });
  }

  void _generateTargetWord() {
    if (widget.words.isEmpty) return;
    setState(() {
      _targetWord = widget.words[_random.nextInt(widget.words.length)];
    });
  }

  void _spawnWord() {
    // С вероятностью 40% спавним целевое слово, иначе случайное
    Word wordToSpawn;
    if (_random.nextDouble() < 0.4 && _targetWord != null) {
      wordToSpawn = _targetWord!;
    } else {
      wordToSpawn = widget.words[_random.nextInt(widget.words.length)];
    }

    setState(() {
      _floatingWords.add(_FloatingWord(
        word: wordToSpawn,
        x: 0.1 + _random.nextDouble() * 0.7, // От 10% до 80% ширины экрана
        y: -0.1, // Начинает чуть выше экрана
        speed: 0.003 + _random.nextDouble() * 0.002, // Скорость падения
        color: _colors[_random.nextInt(_colors.length)],
        id: DateTime.now().millisecondsSinceEpoch + _random.nextInt(9999),
      ));
    });
  }

  void _updatePositions() {
    bool needsUpdate = false;

    // Двигаем слова вниз (увеличиваем Y)
    for (var word in _floatingWords) {
      word.y += word.speed;
      needsUpdate = true;
    }

    // Удаляем слова, улетевшие за экран
    final escapedTarget = _floatingWords.where((w) => w.y > 1.1 && w.word == _targetWord).isNotEmpty;

    _floatingWords.removeWhere((w) => w.y > 1.1);

    if (escapedTarget) {
      _loseLife();
    }

    if (needsUpdate && mounted) {
      setState(() {});
    }
  }

  void _onWordTap(_FloatingWord tappedWord) {
    if (_gameOver) return;

    setState(() {
      _floatingWords.remove(tappedWord);

      if (tappedWord.word == _targetWord) {
        // Правильный ответ!
        _score += 10;
        _generateTargetWord(); // Даём новое слово для поиска
      } else {
        // Неправильный ответ!
        _loseLife();
      }
    });
  }

  void _loseLife() {
    setState(() {
      _lives--;
      if (_lives <= 0) {
        _gameOver = true;
        _gameLoop?.cancel();
        _spawnTimer?.cancel();
        _showGameOver();
      } else {
        // Если потеряли жизнь, меняем целевое слово, чтобы не было путаницы
        _generateTargetWord();
      }
    });
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('💥 Игра окончена!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Твой счёт: $_score',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _score >= 100 ? 'Ты настоящий ниндзя! 🥷' : 'Хорошая попытка! ',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Ещё раз'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Возврат к категориям
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(' Словесный Ниндзя'),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text('$_score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                const Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 4),
                Text('$_lives', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade900, Colors.purple.shade900],
          ),
        ),
        child: Stack(
          children: [
            // Верхняя панель с заданием
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    'Найди и лопни:',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Text(
                      _targetWord?.original ?? '...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '(${_targetWord?.translation ?? ''})',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                  ),
                ],
              ),
            ),

            // Летающие слова
            ..._floatingWords.map((floatingWord) {
              return Positioned(
                left: floatingWord.x * screenWidth,
                top: floatingWord.y * screenHeight,
                child: GestureDetector(
                  onTap: () => _onWordTap(floatingWord),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: floatingWord.color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: floatingWord.color.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      floatingWord.word.original,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Вспомогательный класс для хранения данных о летающем слове
class _FloatingWord {
  final Word word;
  double x;
  double y;
  final double speed;
  final Color color;
  final int id;

  _FloatingWord({
    required this.word,
    required this.x,
    required this.y,
    required this.speed,
    required this.color,
    required this.id,
  });
}