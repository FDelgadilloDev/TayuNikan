import '../database/database_helper.dart';
import '../models/quiz_question.dart';

/// CRUD para preguntas de cuestionario.
class QuizRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  static const String _table = 'quiz_questions';

  Future<List<QuizQuestion>> getQuestionsByLesson(int lessonId) async {
    final maps = await _db.queryWhere(
      _table,
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    return maps.map(QuizQuestion.fromMap).toList();
  }

  Future<int> insertQuestion(QuizQuestion question) async {
    final map = question.toMap();
    map.remove('id');
    return _db.insert(_table, map);
  }

  Future<int> updateQuestion(QuizQuestion question) async {
    return _db.update(
      _table,
      question.toMap(),
      where: 'id = ?',
      whereArgs: [question.id],
    );
  }

  Future<int> deleteQuestion(int id) async {
    return _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteQuestionsForLesson(int lessonId) async {
    return _db.delete(_table,
        where: 'lesson_id = ?', whereArgs: [lessonId]);
  }
}
