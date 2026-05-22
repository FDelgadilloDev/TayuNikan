import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          _SectionHeader(title: 'Acerca de'),
          const ListTile(
            leading: Icon(Icons.info_outline, color: AppColors.primary),
            title: Text('VozViva'),
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
