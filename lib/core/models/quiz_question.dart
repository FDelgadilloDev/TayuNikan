/// Pregunta de opción múltiple para el cuestionario de una lección.
class QuizQuestion {
  final int? id;
  final int lessonId;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption; // 'a', 'b', 'c' o 'd'

  const QuizQuestion({
    this.id,
    required this.lessonId,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) => QuizQuestion(
        id: map['id'] as int?,
        lessonId: map['lesson_id'] as int,
        question: map['question'] as String,
        optionA: map['option_a'] as String,
        optionB: map['option_b'] as String,
        optionC: map['option_c'] as String,
        optionD: map['option_d'] as String,
        correctOption: map['correct_opt'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'lesson_id': lessonId,
        'question': question,
        'option_a': optionA,
        'option_b': optionB,
        'option_c': optionC,
        'option_d': optionD,
        'correct_opt': correctOption,
      };

  /// Devuelve el texto de la opción indicada ('a', 'b', 'c' o 'd').
  String getOptionText(String option) {
    switch (option.toLowerCase()) {
      case 'a':
        return optionA;
      case 'b':
        return optionB;
      case 'c':
        return optionC;
      case 'd':
        return optionD;
      default:
        return '';
    }
  }

  bool isCorrect(String selectedOption) =>
      selectedOption.toLowerCase() == correctOption.toLowerCase();
}
