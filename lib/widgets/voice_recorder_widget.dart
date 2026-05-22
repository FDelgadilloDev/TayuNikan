import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/recording_service.dart';
import '../core/services/speech_service.dart';
import '../core/services/audio_service.dart';

/// Widget para que el estudiante grabe su pronunciación.
/// Incluye botón de grabar, reproducir grabación y recibir retroalimentación.
class VoiceRecorderWidget extends StatefulWidget {
  final String expectedWord; // Palabra que debe pronunciar el estudiante
  final void Function(String result, String? audioPath)? onAttemptSaved;

  const VoiceRecorderWidget({
    super.key,
    required this.expectedWord,
    this.onAttemptSaved,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  final RecordingService _recorder = RecordingService();
  final SpeechService _speech = SpeechService();
  final AudioService _player = AudioService();

  bool _isRecording = false;
  bool _hasRecording = false;
  String? _recordingPath;
  String _recognizedText = '';
  String _feedback = '';
  String _feedbackResult = '';

  @override
  void initState() {
    super.initState();
    _speech.initialize();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      _showSnack('Permiso de micrófono requerido');
      return;
    }

    setState(() {
      _isRecording = true;
      _recognizedText = '';
      _feedback = '';
      _feedbackResult = '';
    });

    _recordingPath = await _recorder.startRecording();

    // Intenta reconocimiento de voz en paralelo con la grabación
    if (_speech.isAvailable) {
      await _speech.startListening(
        onResult: (text) {
          if (mounted) setState(() => _recognizedText = text);
        },
      );
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecording();
    await _speech.stopListening();

    setState(() {
      _isRecording = false;
      _hasRecording = path != null;
      _recordingPath = path;
    });

    _evaluatePronunciation();
  }

  void _evaluatePronunciation() {
    String result;
    String message;

    if (_recognizedText.isEmpty) {
      // Sin reconocimiento de voz disponible para esta lengua
      result = 'saved';
      message = 'Pronunciación registrada. Consulta con tu docente o hablante guía.';
    } else {
      result = _speech.evaluatePronunciation(widget.expectedWord, _recognizedText);
      switch (result) {
        case 'good':
          message = '¡Excelente pronunciación! 🎉';
        case 'try_again':
          message = 'Buen intento. ¡Sigue practicando!';
        default:
          message = 'Pronunciación registrada. Puedes guardarla para revisión.';
      }
    }

    setState(() {
      _feedbackResult = result;
      _feedback = message;
    });

    widget.onAttemptSaved?.call(result, _recordingPath);
  }

  Future<void> _playRecording() async {
    if (_recordingPath != null) {
      await _player.playFile(_recordingPath!);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Color get _feedbackColor {
    switch (_feedbackResult) {
      case 'good':
        return AppColors.feedbackGood;
      case 'try_again':
        return AppColors.feedbackTry;
      default:
        return AppColors.feedbackSaved;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón principal de grabación
        GestureDetector(
          onTap: _isRecording ? _stopRecording : _startRecording,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording ? AppColors.error : AppColors.accent,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? AppColors.error : AppColors.accent)
                      .withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isRecording ? 'Grabando… toca para detener' : 'Toca para grabar',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),

        // Texto reconocido (si hay)
        if (_recognizedText.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Reconocido: "$_recognizedText"',
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],

        // Retroalimentación
        if (_feedback.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _feedbackColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _feedbackColor.withOpacity(0.3)),
            ),
            child: Text(
              _feedback,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _feedbackColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],

        // Botón para reproducir la grabación propia
        if (_hasRecording && !_isRecording) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _playRecording,
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Reproducir mi grabación'),
          ),
        ],
      ],
    );
  }
}
