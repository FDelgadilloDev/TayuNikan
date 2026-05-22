import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/progress_provider.dart';

/// Pantalla de avance del estudiante con estadísticas, insignias y racha.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Avance')),
      body: RefreshIndicator(
        onRefresh: () => progress.loadProgress(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Progreso general
            _ProgressHeader(
              completedLessons: progress.completedLessons,
              totalLessons: progress.totalLessons,
              percentage: progress.completionPercentage,
            ),
            const SizedBox(height: 20),

            // Estadísticas
            _StatsRow(
              streak: progress.practiceStreak,
              wordsPracticed: progress.totalWordsPracticed,
              pronunciationAttempts: progress.totalPronunciationAttempts,
            ),
            const SizedBox(height: 20),

            // Insignia
            _BadgeCard(
              level: progress.badgeLevel,
              label: progress.badgeLabel,
              completedLessons: progress.completedLessons,
            ),

            const SizedBox(height: 20),

            // Motivación
            _MotivationCard(streak: progress.practiceStreak),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets internos ──────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  final int completedLessons;
  final int totalLessons;
  final double percentage;

  const _ProgressHeader({
    required this.completedLessons,
    required this.totalLessons,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progreso general',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${(percentage * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 10,
                backgroundColor: AppColors.lightGray,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$completedLessons de $totalLessons lecciones completadas',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int streak;
  final int wordsPracticed;
  final int pronunciationAttempts;

  const _StatsRow({
    required this.streak,
    required this.wordsPracticed,
    required this.pronunciationAttempts,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            color: AppColors.error,
            value: '$streak',
            label: 'Racha\n(días)',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.spellcheck_rounded,
            color: AppColors.secondary,
            value: '$wordsPracticed',
            label: 'Palabras\npracticadas',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.mic_rounded,
            color: AppColors.accent,
            value: '$pronunciationAttempts',
            label: 'Intentos de\npronunciación',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final int level;
  final String label;
  final int completedLessons;

  const _BadgeCard({
    required this.level,
    required this.label,
    required this.completedLessons,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.lightGray,
      const Color(0xFFCD7F32), // Bronce
      const Color(0xFFC0C0C0), // Plata
      AppColors.accent,         // Oro
    ];

    final color = colors[level.clamp(0, 3)];
    final icons = ['hourglass_empty', '🥉', '🥈', '🥇'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: color.withOpacity(0.2),
              child: Text(
                level == 0 ? '?' : icons[level],
                style: TextStyle(fontSize: 28, color: color),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level == 0 ? 'Sin insignia aún' : 'Insignia $label',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    level == 0
                        ? 'Completa tu primera lección para ganar una insignia.'
                        : level < 3
                            ? 'Completa más lecciones para subir de nivel.'
                            : '¡Máximo nivel alcanzado! ¡Excelente!',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MotivationCard extends StatelessWidget {
  final int streak;
  const _MotivationCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final message = streak == 0
        ? '¡Comienza a practicar hoy para iniciar tu racha!'
        : streak == 1
            ? '¡Llevas 1 día de práctica! ¡Sigue así!'
            : '¡Llevas $streak días seguidos! ¡Increíble constancia!';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🌟', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
