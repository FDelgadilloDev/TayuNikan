import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';

/// Pantalla de configuración.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          // Estado premium
          _SectionHeader(title: 'Versión'),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: auth.isPremium
                  ? AppColors.accent.withOpacity(0.15)
                  : AppColors.lightGray,
              child: Icon(
                Icons.workspace_premium_rounded,
                color: auth.isPremium ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
            title: Text(auth.isPremium ? 'Versión Premium' : 'Versión Gratuita'),
            subtitle: Text(
              auth.isPremium
                  ? 'Sin publicidad. ¡Gracias por tu apoyo!'
                  : 'Con publicidad no invasiva.',
            ),
            trailing: auth.isPremium
                ? null
                : ElevatedButton(
                    onPressed: () => _showPremiumDialog(context, auth),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: const Text('Comprar'),
                  ),
          ),

          const Divider(),
          _SectionHeader(title: 'Administración'),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: auth.isAdminMode
                  ? AppColors.secondary.withOpacity(0.15)
                  : AppColors.lightGray,
              child: Icon(
                Icons.admin_panel_settings_rounded,
                color: auth.isAdminMode
                    ? AppColors.secondary
                    : AppColors.textSecondary,
              ),
            ),
            title: Text(
              auth.isAdminMode ? 'Modo Admin activo' : 'Modo Administrador',
            ),
            subtitle: Text(
              auth.isAdminMode
                  ? 'Puedes crear y editar lecciones.'
                  : 'Accede para crear y editar contenido.',
            ),
            trailing: auth.isAdminMode
                ? TextButton(
                    onPressed: () {
                      auth.logoutAdmin();
                      Navigator.pop(context);
                    },
                    child: const Text('Salir',
                        style: TextStyle(color: AppColors.error)),
                  )
                : const Icon(Icons.chevron_right_rounded),
            onTap: auth.isAdminMode
                ? null
                : () => Navigator.pushNamed(context, AppRoutes.adminLogin),
          ),

          const Divider(),
          _SectionHeader(title: 'Diagnóstico'),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0x1A5F7A35),
              child: Icon(Icons.quiz_outlined, color: AppColors.secondary),
            ),
            title: const Text('Reiniciar diagnóstico de nivel'),
            subtitle: const Text(
              'Repite el examen de diagnóstico para actualizar tu nivel.',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _confirmResetDiagnostic(context),
          ),

          const Divider(),
          _SectionHeader(title: 'Acerca de'),
          const ListTile(
            leading: Icon(Icons.info_outline, color: AppColors.primary),
            title: Text('TayuNikan'),
            subtitle: Text('Versión 1.0.0 — Proyecto ExpoCiencias\n'
                'Categoría: Sociales y Humanidades'),
          ),
          const ListTile(
            leading: Icon(Icons.warning_amber_rounded, color: AppColors.accent),
            title: Text('Aviso sobre el contenido'),
            subtitle: Text(
              'Todo el contenido de la app debe ser validado por '
              'hablantes nativos de la comunidad antes de su uso oficial.',
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmResetDiagnostic(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reiniciar diagnóstico'),
        content: const Text(
          '¿Deseas reiniciar el diagnóstico de nivel? '
          'El estado de tus lecciones no cambiará hasta que completes el examen de nuevo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('diagnosticCompleted', false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diagnóstico reiniciado. Puedes hacerlo desde Lecciones.'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    }
  }

  void _showPremiumDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Comprar Premium'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versión Premium — Sin publicidad'),
            SizedBox(height: 12),
            Text('✓ Elimina todos los anuncios\n'
                '✓ Apoya el proyecto\n'
                '✓ Pago único, sin suscripción'),
            SizedBox(height: 12),
            Text('\$39 MXN',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent)),
            SizedBox(height: 8),
            Text(
              '(Demo: activación gratuita para la presentación)',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.activatePremium();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ ¡Premium activado! Sin anuncios.'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent),
            child: const Text('Activar Premium'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
