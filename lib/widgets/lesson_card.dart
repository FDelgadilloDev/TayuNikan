import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/models/lesson.dart';
import '../core/models/user_progress.dart';
import 'difficulty_indicator.dart';

/// Tarjeta de lección que muestra título, categoría, dificultad y progreso.
class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final UserProgress? progress;
  final int wordCount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isAdminMode;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.onTap,
    this.progress,
    this.wordCount = 0,
    this.onEdit,
    this.onDelete,
    this.isAdminMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final locked = lesson.isLocked;
    // Completada si el modelo lo dice O si el progreso lo dice
    final completed = lesson.isCompleted || (progress?.completed ?? false);
    final completionValue = _calculateCompletion();

    return Opacity(
      opacity: locked ? 0.55 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: completed
              ? const BorderSide(color: AppColors.secondary, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: locked ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila superior: categoría, nivel y opciones admin
                Row(
                  children: [
                    _CategoryChip(category: lesson.category),
                    const SizedBox(width: 8),
                    DifficultyIndicator(difficulty: lesson.difficulty),
                    const Spacer(),
                    if (locked)
                      const Icon(Icons.lock_rounded,
                          color: AppColors.textSecondary, size: 20)
                    else if (completed)
                      const Icon(Icons.check_circle,
                          color: AppColors.secondary, size: 20),
                    if (isAdminMode) ...[
                      const SizedBox(width: 4),
                      _AdminMenu(onEdit: onEdit, onDelete: onDelete),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                // Título de la lección
                Text(
                  lesson.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (locked)
                  Text(
                    'Completa la lección anterior para desbloquear',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                  )
                else
                  Text(
                    '$wordCount ${wordCount == 1 ? "palabra" : "palabras"}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (!locked && lesson.isExample) ...[
                  const SizedBox(height: 4),
                  Text(
                    '⚠ Contenido de demo — requiere validación por hablante nativo',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          color: AppColors.accent,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
                const SizedBox(height: 10),
                // Barra de progreso
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: locked ? 0.0 : completionValue,
                    minHeight: 6,
                    backgroundColor: AppColors.lightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completed ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateCompletion() {
    if (progress == null) return 0.0;
    if (progress!.completed) return 1.0;
    if (wordCount == 0) return 0.0;
    return (progress!.wordsPracticed / wordCount).clamp(0.0, 1.0);
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AdminMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _AdminMenu({this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Text('Editar')),
        const PopupMenuItem(
            value: 'delete',
            child: Text('Eliminar', style: TextStyle(color: AppColors.error))),
      ],
    );
  }
}
