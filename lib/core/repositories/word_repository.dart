import '../database/database_helper.dart';
import '../models/word.dart';

/// CRUD para palabras de una lección.
class WordRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  static const String _table = 'words';

  Future<List<Word>> getWordsByLesson(int lessonId) async {
    final maps = await _db.queryWhere(
      _table,
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    return maps.map(Word.fromMap).toList();
  }

  Future<Word?> getWordById(int id) async {
    final maps =
        await _db.queryWhere(_table, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Word.fromMap(maps.first);
  }

  Future<int> insertWord(Word word) async {
    final map = word.toMap();
    map.remove('id');
    return _db.insert(_table, map);
  }

  Future<int> updateWord(Word word) async {
    return _db.update(
      _table,
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  Future<int> deleteWord(int id) async {
    return _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getWordCountForLesson(int lessonId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM $_table WHERE lesson_id = ?',
      [lessonId],
    );
    return result.first['count'] as int? ?? 0;
  }

  /// Devuelve todas las palabras de la base de datos (para actividades globales).
  Future<List<Word>> getAllWords() async {
    final maps = await _db.queryAll(_table);
    return maps.map(Word.fromMap).toList();
  }
}
