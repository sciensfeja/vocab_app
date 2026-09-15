import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/speech_service.dart';

class FlashcardsScreen extends StatefulWidget {
  final List<Word> words;
  const FlashcardsScreen({super.key, required this.words});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  final SpeechService _speech = SpeechService();

  Word get _currentWord => widget.words[_currentIndex];

  void _next() {
    setState(() {
      _isFlipped = false;
      _currentIndex = (_currentIndex + 1) % widget.words.length;
    });
    _speech.speak(_currentWord.original);
  }

  void _previous() {
    setState(() {
      _isFlipped = false;
      _currentIndex = (_currentIndex - 1 + widget.words.length) % widget.words.length;
    });
    _speech.speak(_currentWord.original);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speech.speak(_currentWord.original);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentWord.category),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('${_currentIndex + 1}/${widget.words.length}'),
            ),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => setState(() => _isFlipped = !_isFlipped),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                height: 300,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isFlipped ? _currentWord.translation : _currentWord.original,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    if (_currentWord.hint != null && _isFlipped) ...[
                      const SizedBox(height: 12),
                      Text(
                        '(${_currentWord.hint})',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                    const SizedBox(height: 24),
                    IconButton(
                      iconSize: 48,
                      onPressed: () => _speech.speak(_currentWord.original),
                      icon: const Icon(Icons.volume_up),
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _previous,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Назад'),
            ),
            ElevatedButton.icon(
              onPressed: _next,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Дальше'),
            ),
          ],
        ),
      ),
    );
  }
}