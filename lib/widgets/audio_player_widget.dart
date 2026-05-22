import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/audio_service.dart';

/// Widget para reproducir el audio de pronunciación correcta.
/// Muestra un botón circular de play/stop con el texto de la palabra.
class AudioPlayerWidget extends StatefulWidget {
  final String? audioPath;      // Ruta local del archivo de audio
  final String? assetPath;      // Ruta en assets (si está empaquetado)
  final String wordLabel;       // Texto que se muestra debajo del botón

  const AudioPlayerWidget({
    super.key,
    this.audioPath,
    this.assetPath,
    required this.wordLabel,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioService.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      try {
        if (widget.audioPath != null && widget.audioPath!.isNotEmpty) {
          await _audioService.playFile(widget.audioPath!);
        } else if (widget.assetPath != null) {
          await _audioService.playAsset(widget.assetPath!);
        }
      } finally {
        if (mounted) setState(() => _isPlaying = false);
      }
    }
  }

  bool get _hasAudio =>
      (widget.audioPath != null && widget.audioPath!.isNotEmpty) ||
      widget.assetPath != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _hasAudio ? _togglePlay : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _hasAudio
                  ? (_isPlaying ? AppColors.secondary : AppColors.primary)
                  : AppColors.lightGray,
              boxShadow: _hasAudio
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Icon(
              _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _hasAudio ? 'Escuchar pronunciación' : 'Sin audio disponible',
          style: TextStyle(
            fontSize: 12,
            color: _hasAudio ? AppColors.textSecondary : AppColors.lightGray,
          ),
        ),
      ],
    );
  }
}
