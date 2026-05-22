import 'package:just_audio/just_audio.dart';

/// Servicio para reproducir audio (pronunciaciones correctas).
/// Soporta archivos locales (grabaciones del admin/hablante) y assets empaquetados.
class AudioService {
  AudioPlayer? _player;

  /// Reproduce un audio desde los assets de la app (e.g., 'assets/audio/hola.mp3').
  Future<void> playAsset(String assetPath) async {
    try {
      await _disposePlayer();
      _player = AudioPlayer();
      await _player!.setAsset(assetPath);
      await _player!.play();
    } catch (e) {
      // Silencia el error para no interrumpir la UI
      // En producción se podría mostrar un SnackBar
    }
  }

  /// Reproduce un audio desde una ruta de archivo local en el dispositivo.
  Future<void> playFile(String filePath) async {
    try {
      await _disposePlayer();
      _player = AudioPlayer();
      await _player!.setFilePath(filePath);
      await _player!.play();
    } catch (e) {
      // Silencia el error
    }
  }

  /// Detiene la reproducción actual.
  Future<void> stop() async {
    await _player?.stop();
  }

  /// Libera los recursos del reproductor.
  Future<void> dispose() async {
    await _disposePlayer();
  }

  Future<void> _disposePlayer() async {
    await _player?.stop();
    await _player?.dispose();
    _player = null;
  }

  /// Stream del estado del reproductor (para actualizar la UI).
  Stream<PlayerState>? get playerStateStream => _player?.playerStateStream;

  /// True si hay audio reproduciéndose actualmente.
  bool get isPlaying => _player?.playing ?? false;
}
