/// Modelo de una palabra o frase en la lengua indígena.
///
/// Nota: El contenido debe ser validado por hablantes nativos de la comunidad.
class Word {
  final int? id;
  final int lessonId;
  final String indigenousWord; // Palabra en la lengua indígena
  final String translation;   // Traducción al español
  final String? audioPath;    // Ruta local al archivo de audio
  final String? imagePath;    // Ruta local a imagen opcional
  final String? examplePhrase; // Frase de ejemplo usando la palabra

  const Word({
    this.id,
    required this.lessonId,
    required this.indigenousWord,
    required this.translation,
    this.audioPath,
    this.imagePath,
    this.examplePhrase,
  });

  factory Word.fromMap(Map<String, dynamic> map) => Word(
        id: map['id'] as int?,
        lessonId: map['lesson_id'] as int,
        indigenousWord: map['indigenous_word'] as String,
        translation: map['translation'] as String,
        audioPath: map['audio_path'] as String?,
        imagePath: map['image_path'] as String?,
        examplePhrase: map['example_phrase'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'lesson_id': lessonId,
        'indigenous_word': indigenousWord,
        'translation': translation,
        'audio_path': audioPath,
        'image_path': imagePath,
        'example_phrase': examplePhrase,
      };

  Word copyWith({
    int? id,
    int? lessonId,
    String? indigenousWord,
    String? translation,
    String? audioPath,
    String? imagePath,
    String? examplePhrase,
  }) =>
      Word(
        id: id ?? this.id,
        lessonId: lessonId ?? this.lessonId,
        indigenousWord: indigenousWord ?? this.indigenousWord,
        translation: translation ?? this.translation,
        audioPath: audioPath ?? this.audioPath,
        imagePath: imagePath ?? this.imagePath,
        examplePhrase: examplePhrase ?? this.examplePhrase,
      );

  /// Indica si la palabra tiene audio disponible.
  bool get hasAudio => audioPath != null && audioPath!.isNotEmpty;

  /// Indica si la palabra tiene imagen.
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  @override
  String toString() =>
      'Word(id: $id, word: $indigenousWord, translation: $translation)';
}
