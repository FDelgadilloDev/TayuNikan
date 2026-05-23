import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/models/quiz_question.dart';
import '../../core/models/word.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/progress_provider.dart';

/// Pantalla de cuestionario de opción múltiple.
class QuizScreen extends StatefulWidget {
  final int lessonId;
  const QuizScreen({super.key, required this.lessonId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedOption;
  bool _answered = false;

  List<QuizQuestion> get _questions =>
      context.read<LessonProvider>().currentQuestions;

  List<Word> get _words => context.read<LessonProvider>().currentWords;

  QuizQuestion get _current => _questions[_currentIndex];

  /// Busca una imagen asociada a la pregunta actual cotejando
  /// palabras Ngigua y traducciones con el texto de la pregunta.
  String? _imageForQuestion(QuizQuestion q) {
    final qLower = q.question.toLowerCase();
    for (final word in _words) {
      final ngiguaLower = word.indigenousWord.toLowerCase();
      final transLower = word.translation.toLowerCase();
      if (qLower.contains(ngiguaLower) || qLower.contains(transLower)) {
        return word.imagePath;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final questions = context.watch<LessonProvider>().currentQuestions;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cuestionario')),
        body: const Center(child: Text('No hay preguntas disponibles.')),
      );
    }

    final total = questions.length;
    final progress = (_currentIndex + 1) / total;
    final imagePath = _imageForQuestion(_current);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pregunta ${_currentIndex + 1} de $total'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primary.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Imagen de la palabra si existe
            if (imagePath != null && imagePath.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    height: 160,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            if (imagePath != null && imagePath.isNotEmpty)
              const SizedBox(height: 16),
            // Pregunta
            Text(
              _current.question,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            // Opciones
            ...['a', 'b', 'c', 'd'].map((opt) => _OptionButton(
                  option: opt,
                  text: _current.getOptionText(opt),
                  selectedOption: _selectedOption,
                  correctOption: _current.correctOption,
                  answered: _answered,
                  onTap: _answered ? null : () => _selectOption(opt),
                )),
            const SizedBox(height: 16),
            // Botón siguiente / finalizar
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentIndex < total - 1 ? 'Siguiente' : 'Ver resultados',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _selectOption(String option) {
    final correct = _current.isCorrect(option);
    setState(() {
      _selectedOption = option;
      _answered = true;
      if (correct) _score++;
    });
  }

  void _nextQuestion() {
    final total = _questions.length;
    if (_currentIndex < total - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      _finishQuiz(total);
    }
  }

  Future<void> _finishQuiz(int total) async {
    final scorePercent = ((_score / total) * 100).round();
    final passed = _score / total >= 0.7;

    // Registrar progreso en user_progress
    if (mounted) {
      context
          .read<ProgressProvider>()
          .markLessonCompleted(widget.lessonId, quizScore: scorePercent);
    }

    // Si pasó ≥70%, desbloquear siguiente lección
    if (passed && mounted) {
      final lessons = context.read<LessonProvider>().lessons;
      final lesson = lessons.where((l) => l.id == widget.lessonId).firstOrNull;
      if (lesson != null) {
        await context
            .read<LessonProvider>()
            .completeLesson(widget.lessonId, lesson.orderIndex);
      }
    }

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.quizResult,
        arguments: {
          'score': _score,
          'total': total,
          'lessonId': widget.lessonId,
        },
      );
    }
  }
}

// ─── Botón de opción ──────────────────────────────────────────────────────────

class _OptionButton extends StatelessWidget {
  final String option;
  final String text;
  final String? selectedOption;
  final String correctOption;
  final bool answered;
  final VoidCallback? onTap;

  const _OptionButton({
    required this.option,
    required this.text,
    required this.selectedOption,
    required this.correctOption,
    required this.answered,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.lightGray;
    Color bgColor = Colors.white;
    Color textColor = AppColors.textPrimary;

    if (answered) {
      final isCorrect = option == correctOption;
      final isSelected = option == selectedOption;

      if (isCorrect) {
        borderColor = AppColors.secondary;
        bgColor = AppColors.secondary.withOpacity(0.1);
        textColor = AppColors.secondary;
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.error;
        bgColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
      }
    } else if (option == selectedOption) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withOpacity(0.05);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: borderColor.withOpacity(0.15),
              child: Text(
                option.toUpperCase(),
                style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: TextStyle(color: textColor, fontSize: 15)),
            ),
            if (answered && option == correctOption)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.secondary, size: 20),
            if (answered && option == selectedOption && option != correctOption)
              const Icon(Icons.cancel_rounded,
                  color: AppColors.error, size: 20),
          ],
        ),
      ),
    );
  }
}
