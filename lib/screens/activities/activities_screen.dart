import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/constants/app_colors.dart';
import '../../core/models/word.dart';
import '../../core/repositories/word_repository.dart';

/// Pantalla de actividades interactivas de práctica.
class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actividades')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Practica con estos ejercicios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _ActivityCard(
            icon: Icons.shuffle_rounded,
            color: AppColors.primary,
            title: 'Relaciona la palabra',
            description: 'Une cada palabra con su traducción correcta.',
            onTap: () => _startActivity(context, _ActivityType.match),
          ),
          _ActivityCard(
            icon: Icons.quiz_rounded,
            color: AppColors.secondary,
            title: 'Selecciona la traducción',
            description: 'Elige la traducción correcta de 4 opciones.',
            onTap: () => _startActivity(context, _ActivityType.multipleChoice),
          ),
          _ActivityCard(
            icon: Icons.flash_on_rounded,
            color: AppColors.accent,
            title: 'Tarjetas de vocabulario',
            description: 'Repasa palabras rápidamente, una por una.',
            onTap: () => _startActivity(context, _ActivityType.flashcard),
          ),
        ],
      ),
    );
  }

  void _startActivity(BuildContext context, _ActivityType type) async {
    final words = await WordRepository().getAllWords();
    if (words.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No hay palabras disponibles. Agrega lecciones primero.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    switch (type) {
      case _ActivityType.match:
        _showMatchActivity(context, words);
      case _ActivityType.multipleChoice:
        _showMultipleChoiceActivity(context, words);
      case _ActivityType.flashcard:
        _showFlashcardActivity(context, words);
    }
  }

  void _showMatchActivity(BuildContext context, List<Word> words) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _MatchActivity(words: words)),
    );
  }

  void _showMultipleChoiceActivity(BuildContext context, List<Word> words) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => _MultipleChoiceActivity(words: words)),
    );
  }

  void _showFlashcardActivity(BuildContext context, List<Word> words) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _FlashcardActivity(words: words)),
    );
  }
}

enum _ActivityType { match, multipleChoice, flashcard }

// ─── Card de actividad ────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 26),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle:
            Text(description, style: const TextStyle(fontSize: 13)),
        trailing: Icon(Icons.play_arrow_rounded, color: color),
        onTap: onTap,
      ),
    );
  }
}

// ─── Actividad: Tarjetas flash ─────────────────────────────────────────────────

class _FlashcardActivity extends StatefulWidget {
  final List<Word> words;
  const _FlashcardActivity({required this.words});

  @override
  State<_FlashcardActivity> createState() => _FlashcardActivityState();
}

class _FlashcardActivityState extends State<_FlashcardActivity> {
  late List<Word> _shuffled;
  int _index = 0;
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    _shuffled = List.from(widget.words)..shuffle(Random());
  }

  void _restart() {
    setState(() {
      _shuffled = List.from(widget.words)..shuffle(Random());
      _index = 0;
      _showTranslation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_shuffled.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tarjetas de vocabulario')),
        body: const Center(child: Text('No hay palabras.')),
      );
    }

    final word = _shuffled[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text('${_index + 1} / ${_shuffled.length}'),
      ),
      body: GestureDetector(
        onTap: () => setState(() => _showTranslation = !_showTranslation),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_index + 1) / _shuffled.length,
                backgroundColor: AppColors.lightGray,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _FlashCard(
                    key: ValueKey('$_index$_showTranslation'),
                    text: _showTranslation
                        ? word.translation
                        : word.indigenousWord,
                    isTranslation: _showTranslation,
                  ),
                ),
              ),
              const Text(
                'Toca la tarjeta para ver la traducción',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (_index > 0)
                    OutlinedButton.icon(
                      onPressed: () => setState(() {
                        _index--;
                        _showTranslation = false;
                      }),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Anterior'),
                    ),
                  if (_index < _shuffled.length - 1)
                    ElevatedButton.icon(
                      onPressed: () => setState(() {
                        _index++;
                        _showTranslation = false;
                      }),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Siguiente'),
                    )
                  else ...[
                    OutlinedButton.icon(
                      onPressed: _restart,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('De nuevo'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('¡Terminé!'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlashCard extends StatelessWidget {
  final String text;
  final bool isTranslation;

  const _FlashCard({super.key, required this.text, required this.isTranslation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isTranslation
            ? AppColors.secondary.withOpacity(0.08)
            : AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isTranslation
              ? AppColors.secondary.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isTranslation ? Icons.spellcheck : Icons.record_voice_over,
                color: isTranslation ? AppColors.secondary : AppColors.primary,
                size: 36,
              ),
              const SizedBox(height: 16),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isTranslation ? AppColors.secondary : AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isTranslation ? 'Español' : 'Lengua indígena',
                style: TextStyle(
                  fontSize: 13,
                  color: (isTranslation ? AppColors.secondary : AppColors.primary)
                      .withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Actividad: Opción múltiple ───────────────────────────────────────────────

class _MultipleChoiceActivity extends StatefulWidget {
  final List<Word> words;
  const _MultipleChoiceActivity({required this.words});

  @override
  State<_MultipleChoiceActivity> createState() =>
      _MultipleChoiceActivityState();
}

class _MultipleChoiceActivityState extends State<_MultipleChoiceActivity> {
  late List<Word> _shuffled;
  int _index = 0;
  int _score = 0;
  String? _selected;
  bool _answered = false;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _shuffled = List.from(widget.words)..shuffle(Random());
    _buildOptions();
  }

  void _buildOptions() {
    final correct = _shuffled[_index].translation;
    final others = widget.words
        .where((w) => w.translation != correct)
        .map((w) => w.translation)
        .toList()
      ..shuffle(Random());
    _options = [correct, ...others.take(3)]..shuffle(Random());
  }

  void _restart() {
    setState(() {
      _shuffled = List.from(widget.words)..shuffle(Random());
      _index = 0;
      _score = 0;
      _selected = null;
      _answered = false;
      _buildOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final word = _shuffled[_index];
    final total = _shuffled.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_index + 1} / $total  •  Puntaje: $_score'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / total,
              backgroundColor: AppColors.lightGray,
            ),
            const SizedBox(height: 24),
            const Text('¿Cómo se traduce?',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(
              word.indigenousWord,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            ..._options.map((opt) {
              Color border = AppColors.lightGray;
              Color bg = Colors.white;
              if (_answered) {
                if (opt == word.translation) {
                  border = AppColors.secondary;
                  bg = AppColors.secondary.withOpacity(0.1);
                } else if (opt == _selected) {
                  border = AppColors.error;
                  bg = AppColors.error.withOpacity(0.1);
                }
              }
              return GestureDetector(
                onTap: _answered ? null : () => _answer(opt, word.translation),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bg,
                    border: Border.all(color: border, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(opt, style: const TextStyle(fontSize: 16)),
                ),
              );
            }),
            const Spacer(),
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_index < total - 1 ? 'Siguiente' : 'Finalizar'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _answer(String option, String correct) {
    setState(() {
      _selected = option;
      _answered = true;
      if (option == correct) _score++;
    });
  }

  void _next() {
    if (_index < _shuffled.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
        _buildOptions();
      });
    } else {
      // Guardar el puntaje antes de mostrar el diálogo
      final finalScore = _score;
      final total = _shuffled.length;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('¡Actividad completa!'),
          content: Text(
            'Puntaje: $finalScore / $total\n'
            '${finalScore == total ? '🎉 ¡Perfecto!' : finalScore >= total ~/ 2 ? '👍 ¡Bien hecho!' : '¡Sigue practicando!'}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);   // cierra diálogo
                Navigator.pop(context); // regresa a actividades
              },
              child: const Text('Volver'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);   // cierra diálogo
                _restart();           // reinicia la actividad
              },
              child: const Text('Jugar de nuevo'),
            ),
          ],
        ),
      );
    }
  }
}

// ─── Actividad: Relacionar ────────────────────────────────────────────────────

class _MatchActivity extends StatefulWidget {
  final List<Word> words;
  const _MatchActivity({required this.words});

  @override
  State<_MatchActivity> createState() => _MatchActivityState();
}

class _MatchActivityState extends State<_MatchActivity> {
  late List<Word> _subset;
  late List<String> _leftItems;
  late List<String> _rightItems;
  Map<String, String> _matches = {};
  String? _selectedWord;
  int _score = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _initRound();
  }

  void _initRound() {
    _subset = (List<Word>.from(widget.words)..shuffle(Random())).take(4).toList();
    _leftItems = _subset.map((w) => w.indigenousWord).toList();
    _rightItems = _subset.map((w) => w.translation).toList()..shuffle(Random());
  }

  void _restart() {
    setState(() {
      _initRound();
      _matches = {};
      _selectedWord = null;
      _score = 0;
      _done = false;
    });
  }

  void _selectLeft(String word) {
    if (_matches.containsKey(word)) return;
    setState(() => _selectedWord = word);
  }

  void _selectRight(String translation) {
    if (_selectedWord == null) return;
    final correct = _subset
        .firstWhere((w) => w.indigenousWord == _selectedWord)
        .translation;
    final isCorrect = translation == correct;

    setState(() {
      _matches[_selectedWord!] = translation;
      if (isCorrect) _score++;
      _selectedWord = null;
      if (_matches.length == _subset.length) _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relaciona la palabra')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!_done) ...[
              const Text(
                'Selecciona una palabra y luego su traducción.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: _leftItems.map((word) {
                          final matched = _matches.containsKey(word);
                          final selected = _selectedWord == word;
                          return GestureDetector(
                            onTap: matched ? null : () => _selectLeft(word),
                            child: _MatchTile(
                              text: word,
                              matched: matched,
                              selected: selected,
                              color: AppColors.primary,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: _rightItems.map((trans) {
                          final matched = _matches.values.contains(trans);
                          return GestureDetector(
                            onTap: matched ? null : () => _selectRight(trans),
                            child: _MatchTile(
                              text: trans,
                              matched: matched,
                              selected: false,
                              color: AppColors.secondary,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🎉',
                        style: TextStyle(fontSize: 72),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Puntaje: $_score / ${_subset.length}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Volver'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _restart,
                            icon: const Icon(Icons.replay_rounded),
                            label: const Text('Jugar de nuevo'),
                          ),
                        ],
                      ),
                    ],
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

class _MatchTile extends StatelessWidget {
  final String text;
  final bool matched;
  final bool selected;
  final Color color;

  const _MatchTile({
    required this.text,
    required this.matched,
    required this.selected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    Color border = AppColors.lightGray;

    if (matched) {
      bg = AppColors.secondary.withOpacity(0.1);
      border = AppColors.secondary;
    } else if (selected) {
      bg = color.withOpacity(0.1);
      border = color;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: selected || matched ? FontWeight.bold : FontWeight.normal,
          color: matched ? AppColors.secondary : AppColors.textPrimary,
          fontSize: 14,
        ),
      ),
    );
  }
}
