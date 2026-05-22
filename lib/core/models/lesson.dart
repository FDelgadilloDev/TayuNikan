/// Modelo de una lección de lengua indígena.
///
/// Nota: El contenido debe ser validado por hablantes nativos de la comunidad.
class Lesson {
  final int? id;
  final String title;
  final String description;
  final String category;
  final int difficulty; // 1=Fácil, 2=Medio, 3=Difícil
  final String createdAt;
  final bool isExample; // true si es contenido de demostración

  const Lesson({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.difficulty = 1,
    required this.createdAt,
    this.isExample = false,
  });

  /// Crea un Lesson desde un mapa de SQLite.
  factory Lesson.fromMap(Map<String, dynamic> map) => Lesson(
        id: map['id'] as int?,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        category: map['category'] as String,
        difficulty: map['difficulty'] as int? ?? 1,
        createdAt: map['created_at'] as String? ?? '',
        isExample: (map['is_example'] as int? ?? 0) == 1,
      );

  /// Convierte a mapa para insertar/actualizar en SQLite.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'difficulty': difficulty,
        'created_at': createdAt,
        'is_example': isExample ? 1 : 0,
      };

  Lesson copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    int? difficulty,
    String? createdAt,
    bool? isExample,
  }) =>
      Lesson(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        difficulty: difficulty ?? this.difficulty,
        createdAt: createdAt ?? this.createdAt,
        isExample: isExample ?? this.isExample,
      );

  String get difficultyLabel {
    switch (difficulty) {
      case 1:
        return 'Fácil';
      case 2:
        return 'Intermedio';
      case 3:
        return 'Difícil';
      default:
        return 'Fácil';
    }
  }

  @override
  String toString() => 'Lesson(id: $id, title: $title, category: $category)';
}
