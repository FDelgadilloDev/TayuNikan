/// Intento de pronunciación del estudiante para una palabra.
///
/// Resultados posibles:
///   'good'     → Pronunciación correcta
///   'try_again'→ Intentar de nuevo
///   'saved'    → Guardado para revisión posterior
///   'review'   → Requiere revisión por docente/hablante
class PronunciationAttempt {
  final int? id;
  final int wordId;
  final String? audioPath;     // Grabación del estudiante
  final String? recognizedText; // Texto reconocido por SpeechRecognizer
  final String result;          // 'good' | 'try_again' | 'saved' | 'review'
  final String attemptedAt;     // ISO 8601

  const PronunciationAttempt({
    this.id,
    required this.wordId,
    this.audioPath,
    this.recognizedText,
    required this.result,
    required this.attemptedAt,
  });

  factory PronunciationAttempt.fromMap(Map<String, dynamic> map) =>
      PronunciationAttempt(
        id: map['id'] as int?,
        wordId: map['word_id'] as int,
        audioPath: map['audio_path'] as String?,
        recognizedText: map['recognized'] as String?,
        result: map['result'] as String? ?? 'saved',
        attemptedAt: map['attempted_at'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'word_id': wordId,
        'audio_path': audioPath,
        'recognized': recognizedText,
        'result': result,
        'attempted_at': attemptedAt,
      };

  /// Mensaje amigable para mostrar al estudiante según el resultado.
  String get feedbackMessage {
    switch (result) {
      case 'good':
        return '¡Excelente pronunciación!';
      case 'try_again':
        return 'Buen intento. ¡Inténtalo de nuevo!';
      case 'saved':
        return 'Pronunciación registrada.';
      case 'review':
        return 'Consulta con tu docente o hablante guía.';
      default:
        return 'Pronunciación registrada.';
    }
  }
}
