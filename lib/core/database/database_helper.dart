import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Clase singleton que gestiona la base de datos SQLite local.
/// Todas las lecciones, palabras, progreso y grabaciones se guardan aquí.
class DatabaseHelper {
  static const String _databaseName = 'vozvia.db';
  static const int _databaseVersion = 1;

  // Singleton
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._privateConstructor();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._privateConstructor();
    return _instance!;
  }

  /// Devuelve la instancia de la base de datos, creándola si no existe.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        // Habilitar claves foráneas en SQLite
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Crea todas las tablas en la primera instalación.
  Future<void> _onCreate(Database db, int version) async {
    // Tabla de lecciones
    await db.execute('''
      CREATE TABLE lessons (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,
        description TEXT    NOT NULL DEFAULT '',
        category    TEXT    NOT NULL,
        difficulty  INTEGER NOT NULL DEFAULT 1,
        created_at  TEXT    NOT NULL,
        is_example  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabla de palabras (vinculadas a una lección)
    await db.execute('''
      CREATE TABLE words (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        lesson_id       INTEGER NOT NULL,
        indigenous_word TEXT    NOT NULL,
        translation     TEXT    NOT NULL,
        audio_path      TEXT,
        image_path      TEXT,
        example_phrase  TEXT,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de preguntas de cuestionario
    await db.execute('''
      CREATE TABLE quiz_questions (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        lesson_id   INTEGER NOT NULL,
        question    TEXT    NOT NULL,
        option_a    TEXT    NOT NULL,
        option_b    TEXT    NOT NULL,
        option_c    TEXT    NOT NULL,
        option_d    TEXT    NOT NULL,
        correct_opt TEXT    NOT NULL,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de progreso del usuario (una fila por lección)
    await db.execute('''
      CREATE TABLE user_progress (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        lesson_id       INTEGER NOT NULL UNIQUE,
        completed       INTEGER NOT NULL DEFAULT 0,
        quiz_score      INTEGER NOT NULL DEFAULT 0,
        words_practiced INTEGER NOT NULL DEFAULT 0,
        last_accessed   TEXT,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de intentos de pronunciación
    await db.execute('''
      CREATE TABLE pronunciation_attempts (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id      INTEGER NOT NULL,
        audio_path   TEXT,
        recognized   TEXT,
        result       TEXT    NOT NULL DEFAULT 'saved',
        attempted_at TEXT    NOT NULL,
        FOREIGN KEY (word_id) REFERENCES words (id) ON DELETE CASCADE
      )
    ''');
  }

  // ──────────────────────────────────────────────
  // Métodos genéricos de acceso a datos
  // ──────────────────────────────────────────────

  /// Inserta una fila y devuelve el ID generado.
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Devuelve todas las filas de una tabla.
  Future<List<Map<String, dynamic>>> queryAll(String table,
      {String? orderBy}) async {
    final db = await database;
    return db.query(table, orderBy: orderBy);
  }

  /// Devuelve filas que cumplan una condición WHERE.
  Future<List<Map<String, dynamic>>> queryWhere(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return db.query(table,
        where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  /// Actualiza filas que cumplan una condición WHERE.
  Future<int> update(
    String table,
    Map<String, dynamic> row, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return db.update(table, row, where: where, whereArgs: whereArgs);
  }

  /// Elimina filas que cumplan una condición WHERE.
  Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Ejecuta una consulta SQL cruda (para agregaciones, etc.).
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, arguments);
  }

  /// Cierra la conexión a la base de datos.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
