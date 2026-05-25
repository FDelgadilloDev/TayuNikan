import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/word.dart';
import '../../core/models/pronunciation_attempt.dart';
import '../../core/repositories/pronunciation_repository.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/audio_player_widget.dart';
import '../../widgets/voice_recorder_widget.dart';

/// Pantalla de detalle de una palabra.
/// Muestra la palabra, traducción, audio correcto y grabación del estudiante.
class WordDetailScreen extends StatelessWidget {
  final Word word;
  const WordDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(word.indigenousWord),
        backgroundColor: AppColors.secondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Palabra principal
            _WordDisplay(word: word),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // Sección: Escuchar pronunciación correcta
            _SectionTitle(
              icon: Icons.volume_up_rounded,
              title: 'Pronunciación correcta',
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            AudioPlayerWidget(
              assetPath: word.audioPath,
              wordLabel: word.indigenousWord,
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // Sección: Grabar pronunciación propia
            _SectionTitle(
              icon: Icons.mic_rounded,
              title: 'Tu pronunciación',
              color: AppColors.accent,
            ),
            const SizedBox(height: 8),
            Text(
              'Escucha el audio correcto y luego graba tu pronunciación.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            VoiceRecorderWidget(
              expectedWord: word.indigenousWord,
              onAttemptSaved: (result, audioPath) {
                _saveAttempt(context, result, audioPath);
              },
            ),

            // Frase de ejemplo (si existe)
            if (word.examplePhrase != null &&
                word.examplePhrase!.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              _ExamplePhrase(phrase: word.examplePhrase!),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAttempt(
      BuildContext context, String result, String? audioPath) async {
    final attempt = PronunciationAttempt(
      wordId: word.id!,
      audioPath: audioPath,
      result: result,
      attemptedAt: DateTime.now().toIso8601String(),
    );
    await PronunciationRepository().insertAttempt(attempt);

    // Actualizar progreso si fue buena pronunciación
    if (result == 'good' && context.mounted) {
      // El progreso se actualiza desde la pantalla padre
    }
  }
}

// ─── Widgets internos ──────────────────────────────────────────────────────────

class _WordDisplay extends StatelessWidget {
  final Word word;
  const _WordDisplay({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Imagen (si existe)
          if (word.hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                word.imagePath!,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          if (word.hasImage) const SizedBox(height: 16),
          // Palabra en lengua indígena (grande y prominente)
          Text(
            word.indigenousWord,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.translation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ExamplePhrase extends StatelessWidget {
  final String phrase;
  const _ExamplePhrase({required this.phrase});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ejemplo de uso:',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            phrase,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
