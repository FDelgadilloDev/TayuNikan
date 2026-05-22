import '../database/database_helper.dart';
import '../models/user_progress.dart';

/// CRUD para el progreso del estudiante.
class ProgressRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  static const String _table = 'user_progress';

  Future<List<UserProgress>> getAllProgress() async {
    final maps = await _db.queryAll(_table);
    return maps.map(UserProgress.fromMap).toList();
  }

  Future<UserProgress?> getProgressForLesson(int lessonId) async {
    final maps = await _db.queryWhere(
      _table,
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    if (maps.isEmpty) return null;
    return UserProgress.fromMap(maps.first);
  }

  /// Inserta o actualiza el progreso de una lección (upsert).
  Future<int> upsertProgress(UserProgress progress) async {
    final existing = await getProgressForLesson(progress.lessonId);
    if (existing == null) {
      final map = progress.toMap();
      map.remove('id');
      return _db.insert(_table, map);
    } else {
      return _db.update(
        _table,
        progress.toMap(),
        where: 'lesson_id = ?',
        whereArgs: [progress.lessonId],
      );
    }
  }

  Future<int> getCompletedCount() async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM $_table WHERE completed = 1',
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getTotalWordsPracticed() async {
    final result = await _db.rawQuery(
      'SELECT SUM(words_practiced) as total FROM $_table',
    );
    return result.first['total'] as int? ?? 0;
  }
}
