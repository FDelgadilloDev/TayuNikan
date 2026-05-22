import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/models/lesson.dart';
import '../../core/models/word.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/progress_provider.dart';

/// Detalle de una lección: descripción, lista de palabras y acceso al quiz.
class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().loadWordsForLesson(widget.lesson.id!);
      context.read<LessonProvider>().loadQuestionsForLesson(widget.lesson.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final auth = context.watch<AuthProvider>();
    final progress = progressProvider.getProgressForLesson(widget.lesson.id!);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        actions: [
          if (auth.isAdminMode)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Agregar palabra',
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.addWord,
                arguments: widget.lesson.id,
              ).then((_) =>
                  lessonProvider.loadWordsForLesson(widget.lesson.id!)),
            ),
        ],
      ),
      body: lessonProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Encabezado de la lección
                SliverToBoxAdapter(
                  child: _LessonHeader(
                    lesson: widget.lesson,
                    wordCount: lessonProvider.currentWords.length,
                    quizAvailable:
                        lessonProvider.currentQuestions.isNotEmpty,
                    progress: progress?.completed ?? false,
                  ),
                ),
                // Lista de palabras
                if (lessonProvider.currentWords.isEmpty)
                  const SliverToBoxAdapter(child: _NoWordsMessage())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final word = lessonProvider.currentWords[index];
                        return _WordTile(
                          word: word,
                          isAdmin: auth.isAdminMode,
                          onDelete: () =>
                              lessonProvider.deleteWord(word),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.wordDetail,
                            arguments: word,
                          ).then((_) => progressProvider
                              .incrementWordsPracticed(widget.lesson.id!)),
                        );
                      },
                      childCount: lessonProvider.currentWords.length,
                    ),
                  ),
                // Botón de quiz
                SliverToBoxAdapter(
                  child: _QuizButton(
                    lessonId: widget.lesson.id!,
                    hasQuestions: lessonProvider.currentQuestions.isNotEmpty,
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Widgets internos ──────────────────────────────────────────────────────────

class _LessonHeader extends StatelessWidget {
  final Lesson lesson;
  final int wordCount;
  final bool quizAvailable;
  final bool progress;

  const _LessonHeader({
    required this.lesson,
    required this.wordCount,
    required this.quizAvailable,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _chip(lesson.category),
              const SizedBox(width: 8),
              _chip(lesson.difficultyLabel),
              const Spacer(),
              if (progress)
                const Icon(Icons.check_circle, color: Colors.white),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lesson.description.isEmpty
                ? 'Aprende vocabulario y pronunciación de esta lección.'
                : lesson.description,
            style: TextStyle(
                color: Colors.white.withOpacity(0.9), height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            '$wordCount ${wordCount == 1 ? "palabra" : "palabras"}  •  '
            '${quizAvailable ? "Cuestionario disponible" : "Sin cuestionario aún"}',
            style: TextStyle(
                color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
          if (lesson.isExample) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '⚠ Contenido de demostración — requiere validación',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      );
}

class _WordTile extends StatelessWidget {
  final Word word;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isAdmin;

  const _WordTile({
    required this.word,
    required this.onTap,
    required this.onDelete,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: const Icon(Icons.record_voice_over_rounded,
            color: AppColors.primary, size: 20),
      ),
      title: Text(
        word.indigenousWord,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary),
      ),
      subtitle: Text(word.translation,
          style: const TextStyle(color: AppColors.textSecondary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (word.hasAudio)
            const Icon(Icons.volume_up_rounded,
                color: AppColors.secondary, size: 18),
          if (isAdmin) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 20),
              onPressed: onDelete,
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

class _NoWordsMessage extends StatelessWidget {
  const _NoWordsMessage();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Text(
          'Esta lección aún no tiene palabras.\n'
          'Un administrador puede agregarlas.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _QuizButton extends StatelessWidget {
  final int lessonId;
  final bool hasQuestions;

  const _QuizButton({required this.lessonId, required this.hasQuestions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: hasQuestions
              ? () => Navigator.pushNamed(context, AppRoutes.quiz,
                  arguments: lessonId)
              : null,
          icon: const Icon(Icons.quiz_rounded),
          label: Text(hasQuestions
              ? 'Hacer cuestionario'
              : 'Cuestionario no disponible'),
        ),
      ),
    );
  }
}
