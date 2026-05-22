import '../database/database_helper.dart';
import '../models/lesson.dart';

/// CRUD para lecciones.
class LessonRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  static const String _table = 'lessons';

  Future<List<Lesson>> getAllLessons() async {
    final maps = await _db.queryAll(_table, orderBy: 'created_at DESC');
    return maps.map(Lesson.fromMap).toList();
  }

  Future<Lesson?> getLessonById(int id) async {
    final maps =
        await _db.queryWhere(_table, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Lesson.fromMap(maps.first);
  }

  Future<List<Lesson>> getLessonsByCategory(String category) async {
    final maps = await _db.queryWhere(
      _table,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'difficulty ASC',
    );
    return maps.map(Lesson.fromMap).toList();
  }

  /// Inserta una lección y devuelve su nuevo ID.
  Future<int> insertLesson(Lesson lesson) async {
    final map = lesson.toMap();
    map.remove('id'); // Dejar que SQLite asigne el ID
    return _db.insert(_table, map);
  }

  Future<int> updateLesson(Lesson lesson) async {
    return _db.update(
      _table,
      lesson.toMap(),
      where: 'id = ?',
      whereArgs: [lesson.id],
    );
  }

  Future<int> deleteLesson(int id) async {
    return _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getTotalCount() async {
    final result = await _db.rawQuery('SELECT COUNT(*) as count FROM $_table');
    return result.first['count'] as int? ?? 0;
  }
}
