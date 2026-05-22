import '../database/database_helper.dart';
import '../models/pronunciation_attempt.dart';

/// CRUD para intentos de pronunciación.
class PronunciationRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  static const String _table = 'pronunciation_attempts';

  Future<List<PronunciationAttempt>> getAttemptsForWord(int wordId) async {
    final maps = await _db.queryWhere(
      _table,
      where: 'word_id = ?',
      whereArgs: [wordId],
      orderBy: 'attempted_at DESC',
    );
    return maps.map(PronunciationAttempt.fromMap).toList();
  }

  Future<int> insertAttempt(PronunciationAttempt attempt) async {
    final map = attempt.toMap();
    map.remove('id');
    return _db.insert(_table, map);
  }

  Future<int> getTotalAttempts() async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM $_table',
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getGoodAttempts() async {
    final result = await _db.rawQuery(
      "SELECT COUNT(*) as count FROM $_table WHERE result = 'good'",
    );
    return result.first['count'] as int? ?? 0;
  }
}
