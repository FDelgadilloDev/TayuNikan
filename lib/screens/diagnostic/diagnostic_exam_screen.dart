import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/models/lesson.dart';
import '../../core/models/quiz_question.dart';
import '../../core/repositories/lesson_repository.dart';
import '../../core/repositories/quiz_repository.dart';
import '../../providers/lesson_provider.dart';

/// Examen diagnóstico inicial: 24 preguntas (2 por cada una de las 12 lecciones).
/// Determina cuántas lecciones puede saltarse el estudiante.
class DiagnosticExamScreen extends StatefulWidget {
  const DiagnosticExamScreen({super.key});

  @override
  State<DiagnosticExamScreen> createState() => _DiagnosticExamScreenState();
}

class _DiagnosticExamScreenState extends State<DiagnosticExamScreen> {
  final _lessonRepo = LessonRepository();
  final _quizRepo = QuizRepository();

  bool _loading = true;

  /// Lista de (lesson, question) en el orden del examen (2 por lección).
  List<(Lesson, QuizQuestion)> _examItems = [];

  int _currentIndex = 0;
  String? _selectedOption;
  bool _answered = false;

  /// Conteo de respuestas correctas por lessonId.
  final Map<int, int> _correctPerLesson = {};

  @override
  void initState() {
    super.initState();
    _buildExam();
  }

  Future<void> _buildExam() async {
    final lessons = await _lessonRepo.getLessonsOrdered();
    final rng = Random();
    final items = <(Lesson, QuizQuestion)>[];

    for (final lesson in lessons) {
      final questions = await _quizRepo.getQuestionsByLesson(lesson.id!);
      if (questions.isEmpty) continue;

      // Seleccionar 2 preguntas al azar (sin repetir)
      questions.shuffle(rng);
      final selected = questions.take(2).toList();
      for (final q in selected) {
        items.add((lesson, q));
      }
      _correctPerLesson[lesson.id!] = 0;
    }

    if (mounted) {
      setState(() {
        _examItems = items;
        _loading = false;
      });
    }
  }

  Lesson get _currentLesson => _examItems[_currentIndex].$1;
  QuizQuestion get _currentQuestion => _examItems[_currentIndex].$2;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diagnóstico de nivel')),
        body:
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_examItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diagnóstico de nivel')),
        body: const Center(child: Text('No hay preguntas disponibles.')),
      );
    }

    final total = _examItems.length;
    final progress = (_currentIndex + 1) / total;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) _showCancelDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Diagnóstico  ${_currentIndex + 1}/$total'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Cancelar diagnóstico',
            onPressed: _showCancelDialog,
          ),
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
              // Chip con nombre de la lección
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentLesson.title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Pregunta
              Text(
                _currentQuestion.question,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              // Opciones
              ...['a', 'b', 'c', 'd'].map((opt) => _DiagOption(
                    option: opt,
                    text: _currentQuestion.getOptionText(opt),
                    selectedOption: _selectedOption,
                    correctOption: _currentQuestion.correctOption,
                    answered: _answered,
                    onTap: _answered ? null : () => _selectOption(opt),
                  )),
              const SizedBox(height: 16),
              if (_answered)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    child: Text(
                      _currentIndex < total - 1
                          ? 'Siguiente'
                          : 'Ver resultado',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectOption(String option) {
    final correct = _currentQuestion.isCorrect(option);
    if (correct) {
      _correctPerLesson[_currentLesson.id!] =
          (_correctPerLesson[_currentLesson.id!] ?? 0) + 1;
    }
    setState(() {
      _selectedOption = option;
      _answered = true;
    });
  }

  void _next() {
    final total = _examItems.length;
    if (_currentIndex < total - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      _finishExam();
    }
  }

  Future<void> _finishExam() async {
    // Aplicar regla secuencial: si una lección falla, ella y las siguientes
    // quedan bloqueadas aunque hayan sido aprobadas en el diagnóstico.
    final lessons = await _lessonRepo.getLessonsOrdered();
    final results = <int, bool>{}; // lessonId → passed?
    final lessonTitles = <int, String>{};
    final toUnlock = <int>[]; // lessonIds que se marcarán completadas+desbloqueadas

    bool blocked = false;
    for (final lesson in lessons) {
      lessonTitles[lesson.id!] = lesson.title;
      final correct = _correctPerLesson[lesson.id!] ?? 0;
      final passed = correct >= 1; // ≥1 de 2 correctas

      if (blocked || !passed) {
        results[lesson.id!] = false;
        blocked = true; // todas las siguientes también bloqueadas
      } else {
        results[lesson.id!] = true;
        toUnlock.add(lesson.id!);
      }
    }

    // La primera lección siempre está desbloqueada (aunque falle el diagnóstico)
    if (lessons.isNotEmpty) {
      final first = lessons.first;
      if (!toUnlock.contains(first.id)) {
        await _lessonRepo.unlockNext(first.orderIndex); // desbloquea order_index 1
      }
    }

    // Persistir desbloqueos
    if (toUnlock.isNotEmpty) {
      await _lessonRepo.unlockLessons(toUnlock);
    }

    // Marcar diagnóstico como completado
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('diagnosticCompleted', true);

    // Recargar lecciones en el provider
    if (mounted) {
      await context.read<LessonProvider>().loadLessons();
    }

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.diagnosticResult,
        arguments: {
          'results': results,
          'lessonTitles': lessonTitles,
        },
      );
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar diagnóstico?'),
        content: const Text(
          'Si cancelas, comenzarás desde la Lección 1. '
          'Puedes hacer el diagnóstico más tarde desde la lista de lecciones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continuar examen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);   // cierra dialog
              Navigator.pop(context); // regresa a LessonListScreen
            },
            child: const Text('Salir',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Botón de opción del diagnóstico ────────────────────────────────────────

class _DiagOption extends StatelessWidget {
  final String option;
  final String text;
  final String? selectedOption;
  final String correctOption;
  final bool answered;
  final VoidCallback? onTap;

  const _DiagOption({
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
      if (option == correctOption) {
        borderColor = AppColors.secondary;
        bgColor = AppColors.secondary.withOpacity(0.1);
        textColor = AppColors.secondary;
      } else if (option == selectedOption) {
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
              child: Text(text, style: TextStyle(color: textColor, fontSize: 15)),
            ),
            if (answered && option == correctOption)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.secondary, size: 20),
            if (answered && option == selectedOption && option != correctOption)
              const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
          ],
        ),
      ),
    );
  }
}
