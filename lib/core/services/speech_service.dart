import 'package:speech_to_text/speech_to_text.dart';

/// Servicio de reconocimiento de voz.
///
/// IMPORTANTE: El reconocimiento de voz puede NO funcionar bien con lenguas
/// indígenas, ya que los motores de reconocimiento no están entrenados para
/// ellas. La app ofrece alternativas: comparación básica, guardar grabación
/// o revisión por docente/hablante nativo.
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  String _recognizedText = '';

  /// Inicializa el motor de reconocimiento de voz.
  /// Devuelve true si está disponible en el dispositivo.
  Future<bool> initialize() async {
    _isInitialized = await _speech.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    return _isInitialized;
  }

  /// Inicia la escucha y llama [onResult] con cada resultado parcial.
  /// [localeId]: idioma para el reconocimiento (por defecto 'es_MX').
  ///             Para lenguas indígenas puede no haber soporte nativo.
  Future<void> startListening({
    required void Function(String text) onResult,
    String localeId = 'es_MX',
  }) async {
    if (!_isInitialized) await initialize();
    if (!_isInitialized) return;

    await _speech.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        onResult(_recognizedText);
      },
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isInitialized;
  String get recognizedText => _recognizedText;

  void clearRecognized() => _recognizedText = '';

  /// Evalúa la pronunciación comparando el texto esperado con el reconocido.
  ///
  /// Retorna:
  ///   'good'      → Coincidencia exacta o muy cercana
  ///   'try_again' → Hay similitud parcial
  ///   'saved'     → No hay coincidencia, se guarda para revisión
  String evaluatePronunciation(String expected, String recognized) {
    final exp = _normalize(expected);
    final rec = _normalize(recognized);

    if (rec.isEmpty) return 'saved';
    if (rec == exp) return 'good';
    if (rec.contains(exp) || exp.contains(rec)) return 'try_again';
    // Comparación por caracteres en común
    final similarity = _similarity(exp, rec);
    if (similarity > 0.6) return 'try_again';
    return 'saved';
  }

  String _normalize(String text) =>
      text.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Similitud de Dice coefficient simplificada.
  double _similarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    if (a == b) return 1.0;
    final aChars = a.split('');
    final bChars = b.split('');
    int matches = 0;
    for (final c in aChars) {
      if (bChars.contains(c)) {
        matches++;
        bChars.remove(c);
      }
    }
    return (2.0 * matches) / (aChars.length + b.length);
  }
}
