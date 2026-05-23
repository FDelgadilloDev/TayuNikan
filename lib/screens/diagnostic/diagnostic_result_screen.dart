import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

/// Muestra el resultado del examen diagnóstico: qué lecciones se desbloquearon.
class DiagnosticResultScreen extends StatelessWidget {
  /// lessonId → true si fue aprobada y desbloqueada, false si quedó bloqueada.
  final Map<int, bool> results;

  /// lessonId → título de la lección (para mostrar en la lista).
  final Map<int, String> lessonTitles;

  const DiagnosticResultScreen({
    super.key,
    required this.results,
    required this.lessonTitles,
  });

  @override
  Widget build(BuildContext context) {
    // Ordenar los ids según el orden natural (menor id = primera lección)
    final sortedIds = results.keys.toList()..sort();
    final passed = sortedIds.where((id) => results[id] == true).length;
    final total = sortedIds.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu nivel en Ngigua'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Cabecera con resultado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              children: [
                const Icon(Icons.school_rounded, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Conoces $passed de $total temas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  passed == total
                      ? '¡Excelente! Tienes todas las lecciones disponibles.'
                      : passed == 0
                          ? 'Comenzarás desde la primera lección. ¡Tú puedes!'
                          : 'Las lecciones que ya conoces están marcadas como completadas.',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Lista de lecciones con resultado
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sortedIds.length,
              itemBuilder: (context, index) {
                final id = sortedIds[index];
                final approved = results[id] ?? false;
                final title = lessonTitles[id] ?? 'Lección ${index + 1}';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: approved
                        ? AppColors.secondary.withOpacity(0.15)
                        : AppColors.lightGray,
                    child: Icon(
                      approved
                          ? Icons.check_circle_rounded
                          : Icons.lock_rounded,
                      color: approved
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      color: approved
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: approved
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    approved ? 'Completada ✓' : 'Por aprender',
                    style: TextStyle(
                      fontSize: 12,
                      color: approved
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),

          // Botón de inicio
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Volver a la lista de lecciones (quitar todo hasta home)
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('¡Comenzar!'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
