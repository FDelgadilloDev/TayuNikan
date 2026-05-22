/// Progreso del estudiante en una lección específica.
class UserProgress {
  final int? id;
  final int lessonId;
  final bool completed;
  final int quizScore;       // Puntaje del último cuestionario (0-100)
  final int wordsPracticed;  // Cantidad de palabras practicadas
  final String? lastAccessed; // ISO 8601 fecha/hora del último acceso

  const UserProgress({
    this.id,
    required this.lessonId,
    this.completed = false,
    this.quizScore = 0,
    this.wordsPracticed = 0,
    this.lastAccessed,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) => UserProgress(
        id: map['id'] as int?,
        lessonId: map['lesson_id'] as int,
        completed: (map['completed'] as int? ?? 0) == 1,
        quizScore: map['quiz_score'] as int? ?? 0,
        wordsPracticed: map['words_practiced'] as int? ?? 0,
        lastAccessed: map['last_accessed'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'lesson_id': lessonId,
        'completed': completed ? 1 : 0,
        'quiz_score': quizScore,
        'words_practiced': wordsPracticed,
        'last_accessed': lastAccessed,
      };

  UserProgress copyWith({
    int? id,
    int? lessonId,
    bool? completed,
    int? quizScore,
    int? wordsPracticed,
    String? lastAccessed,
  }) =>
      UserProgress(
        id: id ?? this.id,
        lessonId: lessonId ?? this.lessonId,
        completed: completed ?? this.completed,
        quizScore: quizScore ?? this.quizScore,
        wordsPracticed: wordsPracticed ?? this.wordsPracticed,
        lastAccessed: lastAccessed ?? this.lastAccessed,
      );
}
