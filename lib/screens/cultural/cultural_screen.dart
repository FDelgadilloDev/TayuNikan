import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Sección cultural: contexto sobre la lengua indígena y su comunidad.
/// Nota: El contenido debe ser validado y proporcionado por la comunidad.
class CulturalScreen extends StatelessWidget {
  const CulturalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sección Cultural')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner de validación importante
          _ValidationBanner(),
          const SizedBox(height: 20),

          // Sobre la lengua
          _InfoSection(
            icon: Icons.language_rounded,
            color: AppColors.primary,
            title: 'Sobre [NOMBRE_DE_LA_LENGUA]',
            content:
                '[Este espacio mostrará información sobre la lengua: familia '
                'lingüística, número de hablantes, variantes dialectales, '
                'situación actual de vitalidad y esfuerzos de preservación.]\n\n'
                'Nota: Este contenido debe ser proporcionado y validado por '
                'hablantes nativos o representantes de la comunidad.',
          ),

          // Sobre la comunidad
          _InfoSection(
            icon: Icons.people_rounded,
            color: AppColors.secondary,
            title: 'La comunidad de [COMUNIDAD_O_REGION]',
            content:
                '[Este espacio mostrará información sobre la comunidad: '
                'ubicación geográfica, tradiciones, festividades, gastronomía, '
                'artesanía y otros elementos culturales relevantes.]\n\n'
                'El contenido final debe ser aprobado por la comunidad.',
          ),

          // Por qué preservar
          _InfoSection(
            icon: Icons.favorite_rounded,
            color: AppColors.accent,
            title: '¿Por qué preservar las lenguas indígenas?',
            content:
                'Cada lengua representa una forma única de ver y entender el '
                'mundo. Cuando una lengua desaparece, se pierde conocimiento '
                'irreemplazable sobre medicina tradicional, ecología, historia '
                'oral y formas de organización social.\n\n'
                'México reconoce 68 lenguas indígenas nacionales en su '
                'Constitución (Artículo 2). La UNESCO estima que más del 40% '
                'de las lenguas del mundo están en peligro de extinción.',
          ),

          // Cómo contribuir
          _InfoSection(
            icon: Icons.volunteer_activism_rounded,
            color: AppColors.secondary,
            title: '¿Cómo puedes contribuir?',
            content:
                '• Aprende y practica la lengua con respeto.\n'
                '• Comparte el aprendizaje con otros.\n'
                '• Apoya iniciativas de documentación lingüística.\n'
                '• Escucha a los hablantes nativos como los expertos que son.\n'
                '• No reproduzcas información sin validación de la comunidad.',
          ),

          const SizedBox(height: 20),
          _FunFactCard(),
        ],
      ),
    );
  }
}

// ─── Widgets internos ──────────────────────────────────────────────────────────

class _ValidationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.accent, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Aviso importante: El contenido cultural de esta sección '
              'es un placeholder de demostración. Todo el contenido final '
              'DEBE ser revisado, aprobado y proporcionado por hablantes '
              'nativos o representantes de la comunidad.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String content;

  const _InfoSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FunFactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.secondary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('🌍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text(
            'Dato cultural',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '[Aquí se mostrará un dato interesante sobre la lengua o '
            'cultura, proporcionado y validado por la comunidad.]\n\n'
            'Ejemplo: "En [NOMBRE_DE_LA_LENGUA], existen más de 30 '
            'formas diferentes de describir los colores del cielo."',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
