import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lesson_provider.dart';

/// Panel de control del administrador.
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lessonCount =
        context.watch<LessonProvider>().lessons.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: AppColors.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Salir del modo admin',
            onPressed: () {
              context.read<AuthProvider>().logoutAdmin();
              Navigator.popUntil(context, (r) => r.isFirst);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Info de estado
          _InfoCard(lessonCount: lessonCount),
          const SizedBox(height: 20),

          // Acciones principales
          _ActionTile(
            icon: Icons.add_circle_rounded,
            color: AppColors.primary,
            title: 'Crear nueva lección',
            subtitle: 'Agrega título, descripción, categoría y nivel',
            onTap: () => Navigator.pushNamed(context, AppRoutes.createLesson)
                .then((_) => context.read<LessonProvider>().loadLessons()),
          ),
          _ActionTile(
            icon: Icons.menu_book_rounded,
            color: AppColors.secondary,
            title: 'Ver todas las lecciones',
            subtitle: 'Edita o elimina lecciones existentes',
            onTap: () => Navigator.pop(context),
          ),
          _ActionTile(
            icon: Icons.workspace_premium_rounded,
            color: AppColors.accent,
            title: 'Activar Premium',
            subtitle: 'Elimina los anuncios de la app',
            onTap: () => _showPremiumDialog(context),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),

          // Nota importante
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.accent, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Recuerda: Todo el contenido debe ser validado por '
                    'hablantes nativos de la comunidad antes de compartirse '
                    'como material oficial.',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Activar Premium'),
        content: const Text(
          'La versión Premium elimina toda la publicidad de la app.\n\n'
          'Precio sugerido: \$39 MXN (pago único)\n\n'
          '(Demo: se activa sin pago para la presentación)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthProvider>().activatePremium();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Modo Premium activado'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent),
            child: const Text('Activar'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final int lessonCount;
  const _InfoCard({required this.lessonCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings_rounded,
              color: AppColors.secondary, size: 36),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Modo Administrador activo',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary)),
              Text('$lessonCount lecciones en la base de datos',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
