import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

/// Pantalla de resultados del cuestionario.
class QuizResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final int lessonId;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.lessonId,
  });

  double get _percentage => total == 0 ? 0 : score / total;

  @override
  Widget build(BuildContext context) {
    final passed = _percentage >= 0.6;
    final color = passed ? AppColors.secondary : AppColors.accent;
    final emoji = _percentage == 1.0
        ? '🏆'
        : _percentage >= 0.8
            ? '🌟'
            : _percentage >= 0.6
                ? '👍'
                : '💪';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 24),
              Text(
                '$score / $total',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_percentage * 100).round()}% correcto',
                style: TextStyle(fontSize: 20, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                passed
                    ? '¡Muy bien! Has completado esta lección.'
                    : 'Sigue practicando, ¡ya casi lo tienes!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  ),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Ir al inicio'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Regresar a la lección para seguir practicando
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Volver a la lección'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
