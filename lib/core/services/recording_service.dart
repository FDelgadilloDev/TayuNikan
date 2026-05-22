import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

/// Servicio para grabar la voz del estudiante.
/// Los archivos se guardan localmente en el almacenamiento de la app.
class RecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;

  /// Verifica si la app tiene permiso para usar el micrófono.
  Future<bool> hasPermission() async {
    return _recorder.hasPermission();
  }

  /// Inicia la grabación de audio.
  /// Devuelve la ruta donde se guardará el archivo, o null si falla.
  Future<String?> startRecording() async {
    if (!await hasPermission()) return null;

    // Crear la carpeta de grabaciones si no existe
    final appDir = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory(p.join(appDir.path, 'recordings'));
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    // Nombre único basado en timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _currentRecordingPath =
        p.join(recordingsDir.path, 'pronunciacion_$timestamp.m4a');

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000,    // Calidad razonable con tamaño pequeño
        sampleRate: 22050, // Suficiente para voz
      ),
      path: _currentRecordingPath!,
    );

    return _currentRecordingPath;
  }

  /// Detiene la grabación y devuelve la ruta del archivo guardado.
  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    return path ?? _currentRecordingPath;
  }

  /// True si la grabación está activa en este momento.
  Future<bool> isRecording() async {
    return _recorder.isRecording();
  }

  /// Libera los recursos del grabador.
  Future<void> dispose() async {
    await _recorder.dispose();
  }

  String? get lastRecordingPath => _currentRecordingPath;
}
