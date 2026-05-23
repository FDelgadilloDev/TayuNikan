# TayuNikan A1 Expansion — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expand TayuNikan from 5 demo lessons to a full CEFR A1 Ngigua curriculum with 12 sequential lessons, a diagnostic exam, and visual watercolor images per word.

**Architecture:** Add `order_index`, `is_locked`, `is_completed` columns to the `lessons` table (DB v1→v2 migration). LessonRepository gets four new methods; LessonProvider gets `completeLesson()`. Two new screens handle the diagnostic exam. The seeder is fully expanded.

**Tech Stack:** Flutter/Dart, sqflite, Provider, shared_preferences, MET Open Access API (image download via Python)

---

## File Map

| File | Action |
|------|--------|
| `lib/core/database/database_helper.dart` | Modify — bump version, add `onUpgrade`, new cols in `_onCreate` |
| `lib/core/models/lesson.dart` | Modify — add 3 fields |
| `lib/core/repositories/lesson_repository.dart` | Modify — add 4 methods |
| `lib/providers/lesson_provider.dart` | Modify — new `loadLessons` + `completeLesson` |
| `lib/screens/quiz/quiz_screen.dart` | Modify — trigger unlock at ≥70% |
| `lib/widgets/lesson_card.dart` | Modify — lock state visual |
| `lib/screens/lessons/lesson_list_screen.dart` | Modify — disable locked taps + diagnostic button |
| `lib/core/constants/app_routes.dart` | Modify — add diagnostic route |
| `lib/app.dart` | Modify — register diagnostic route |
| `lib/screens/diagnostic/diagnostic_exam_screen.dart` | **Create** |
| `lib/screens/diagnostic/diagnostic_result_screen.dart` | **Create** |
| `lib/screens/settings/settings_screen.dart` | Modify — reset diagnostic option |
| `lib/core/database/database_seeder.dart` | Modify — 12 lessons, 10+ questions each |
| `assets/images/` | Add ~55 new watercolor images |

---

## Task 1: DB Migration v1 → v2

**Files:**
- Modify: `lib/core/database/database_helper.dart`

- [ ] **Step 1: Update `_databaseVersion` and `_onCreate`**

Replace the entire `database_helper.dart` content:

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = 'tayunikan.db';
  static const int _databaseVersion = 2;

  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._privateConstructor();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._privateConstructor();
    return _instance!;
  }

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
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lessons (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,
        description TEXT    NOT NULL DEFAULT '',
        category    TEXT    NOT NULL,
        difficulty  INTEGER NOT NULL DEFAULT 1,
        created_at  TEXT    NOT NULL,
        is_example  INTEGER NOT NULL DEFAULT 0,
        order_index INTEGER NOT NULL DEFAULT 0,
        is_locked   INTEGER NOT NULL DEFAULT 1,
        is_completed INTEGER NOT NULL DEFAULT 0
      )
    ''');
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

  /// Migration: adds 3 columns to lessons; unlocks all existing rows
  /// (users who had v1 already played with all lessons freely).
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE lessons ADD COLUMN order_index  INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE lessons ADD COLUMN is_locked    INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE lessons ADD COLUMN is_completed INTEGER NOT NULL DEFAULT 0');
      // Set sequential order_index = id (1-5 for existing lessons)
      await db.execute('UPDATE lessons SET order_index = id');
    }
  }

  // ── Generic helpers ────────────────────────────────────────────────────────

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table,
      {String? orderBy}) async {
    final db = await database;
    return db.query(table, orderBy: orderBy);
  }

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

  Future<int> update(
    String table,
    Map<String, dynamic> row, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return db.update(table, row, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table,
      {required String where, required List<dynamic> whereArgs}) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    final db = await database;
    return db.rawQuery(sql, arguments);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
```

- [ ] **Step 2: Commit**
```bash
git add lib/core/database/database_helper.dart
git commit -m "feat: DB migration v1→v2, add order_index/is_locked/is_completed to lessons"
```

---

## Task 2: Lesson Model — Add 3 Fields

**Files:**
- Modify: `lib/core/models/lesson.dart`

- [ ] **Step 1: Replace lesson.dart**

```dart
class Lesson {
  final int? id;
  final String title;
  final String description;
  final String category;
  final int difficulty;
  final String createdAt;
  final bool isExample;
  final int orderIndex;
  final bool isLocked;
  final bool isCompleted;

  const Lesson({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.difficulty = 1,
    required this.createdAt,
    this.isExample = false,
    this.orderIndex = 0,
    this.isLocked = false,
    this.isCompleted = false,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) => Lesson(
        id: map['id'] as int?,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        category: map['category'] as String,
        difficulty: map['difficulty'] as int? ?? 1,
        createdAt: map['created_at'] as String? ?? '',
        isExample: (map['is_example'] as int? ?? 0) == 1,
        orderIndex: map['order_index'] as int? ?? 0,
        isLocked: (map['is_locked'] as int? ?? 0) == 1,
        isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'difficulty': difficulty,
        'created_at': createdAt,
        'is_example': isExample ? 1 : 0,
        'order_index': orderIndex,
        'is_locked': isLocked ? 1 : 0,
        'is_completed': isCompleted ? 1 : 0,
      };

  Lesson copyWith({
    int? id, String? title, String? description, String? category,
    int? difficulty, String? createdAt, bool? isExample,
    int? orderIndex, bool? isLocked, bool? isCompleted,
  }) =>
      Lesson(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        difficulty: difficulty ?? this.difficulty,
        createdAt: createdAt ?? this.createdAt,
        isExample: isExample ?? this.isExample,
        orderIndex: orderIndex ?? this.orderIndex,
        isLocked: isLocked ?? this.isLocked,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  String get difficultyLabel {
    switch (difficulty) {
      case 1: return 'Fácil';
      case 2: return 'Intermedio';
      case 3: return 'Difícil';
      default: return 'Fácil';
    }
  }

  @override
  String toString() =>
      'Lesson(id: $id, title: $title, order: $orderIndex, locked: $isLocked)';
}
```

- [ ] **Step 2: Commit**
```bash
git add lib/core/models/lesson.dart
git commit -m "feat: add orderIndex, isLocked, isCompleted to Lesson model"
```

---

## Task 3: LessonRepository — New Methods

**Files:**
- Modify: `lib/core/repositories/lesson_repository.dart`

- [ ] **Step 1: Add 4 methods to `LessonRepository`**

Append these methods inside the class (after `getTotalCount`):

```dart
  /// Returns all lessons ordered by order_index (sequential curriculum order).
  Future<List<Lesson>> getLessonsOrdered() async {
    final maps = await _db.queryAll(_table, orderBy: 'order_index ASC');
    return maps.map(Lesson.fromMap).toList();
  }

  /// Marks a lesson as completed in the lessons table.
  Future<void> markCompleted(int lessonId) async {
    await _db.update(
      _table,
      {'is_completed': 1},
      where: 'id = ?',
      whereArgs: [lessonId],
    );
  }

  /// Unlocks the lesson whose order_index equals [nextOrderIndex].
  Future<void> unlockNext(int nextOrderIndex) async {
    await _db.update(
      _table,
      {'is_locked': 0},
      where: 'order_index = ?',
      whereArgs: [nextOrderIndex],
    );
  }

  /// Batch-unlocks and marks as completed a list of lesson IDs (for diagnostic).
  Future<void> unlockLessons(List<int> lessonIds) async {
    if (lessonIds.isEmpty) return;
    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();
    for (final id in lessonIds) {
      batch.update(
        _table,
        {'is_locked': 0, 'is_completed': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }
```

Also update the import at the top if `DatabaseHelper` is not already imported directly — it already is via `_db`.

- [ ] **Step 2: Commit**
```bash
git add lib/core/repositories/lesson_repository.dart
git commit -m "feat: add getLessonsOrdered, markCompleted, unlockNext, unlockLessons to LessonRepository"
```

---

## Task 4: LessonProvider — Update loadLessons + completeLesson

**Files:**
- Modify: `lib/providers/lesson_provider.dart`

- [ ] **Step 1: Replace `loadLessons()` and add `completeLesson()`**

Change the `loadLessons` method body:
```dart
  Future<void> loadLessons() async {
    _setLoading(true);
    try {
      _lessons = await _lessonRepo.getLessonsOrdered();   // ordered by order_index
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
```

Add this method after `deleteLesson`:
```dart
  /// Called when a quiz is passed (≥70%). Marks the lesson completed and
  /// unlocks the next one in sequence.
  Future<void> completeLesson(int lessonId, int orderIndex) async {
    await _lessonRepo.markCompleted(lessonId);
    await _lessonRepo.unlockNext(orderIndex + 1);
    await loadLessons(); // refresh list
  }
```

- [ ] **Step 2: Commit**
```bash
git add lib/providers/lesson_provider.dart
git commit -m "feat: LessonProvider uses getLessonsOrdered, adds completeLesson()"
```

---

## Task 5: QuizScreen — Trigger Unlock at ≥70%

**Files:**
- Modify: `lib/screens/quiz/quiz_screen.dart`

- [ ] **Step 1: Update `_nextQuestion()` to call `completeLesson` and show images**

Replace the `_nextQuestion` method and add the image helper. Full updated `quiz_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/models/quiz_question.dart';
import '../../core/models/word.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/progress_provider.dart';

class QuizScreen extends StatefulWidget {
  final int lessonId;
  const QuizScreen({super.key, required this.lessonId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedOption;
  bool _answered = false;

  List<QuizQuestion> get _questions =>
      context.read<LessonProvider>().currentQuestions;
  List<Word> get _words => context.read<LessonProvider>().currentWords;

  QuizQuestion get _current => _questions[_currentIndex];

  /// Finds an image path associated with this question (looks up words by
  /// matching indigenous word or translation appearing in the question text).
  String? _imageForQuestion(QuizQuestion q) {
    for (final w in _words) {
      if (q.question.contains(w.indigenousWord) ||
          q.question.contains(w.translation)) {
        return w.imagePath;
      }
    }
    // Fallback: match correct answer text
    final correctText = q.getOptionText(q.correctOption);
    for (final w in _words) {
      if (w.indigenousWord == correctText || w.translation == correctText) {
        return w.imagePath;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final questions = context.watch<LessonProvider>().currentQuestions;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cuestionario')),
        body: const Center(child: Text('No hay preguntas disponibles.')),
      );
    }

    final total = questions.length;
    final progress = (_currentIndex + 1) / total;
    final imagePath = _imageForQuestion(_current);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pregunta ${_currentIndex + 1} de $total'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primary.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Imagen de pista (si existe)
            if (imagePath != null) ...[
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              _current.question,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ...['a', 'b', 'c', 'd'].map((opt) => _OptionButton(
                  option: opt,
                  text: _current.getOptionText(opt),
                  selectedOption: _selectedOption,
                  correctOption: _current.correctOption,
                  answered: _answered,
                  onTap: _answered ? null : () => _selectOption(opt),
                )),
            const Spacer(),
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentIndex < total - 1 ? 'Siguiente' : 'Ver resultados',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
      _answered = true;
      if (_current.isCorrect(option)) _score++;
    });
  }

  void _nextQuestion() {
    final total = _questions.length;
    if (_currentIndex < total - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      _finishQuiz(total);
    }
  }

  Future<void> _finishQuiz(int total) async {
    final scorePercent = ((_score / total) * 100).round();
    final passed = _score / total >= 0.7; // 70% umbral de desbloqueo

    // 1. Actualizar progreso existente
    if (mounted) {
      context
          .read<ProgressProvider>()
          .markLessonCompleted(widget.lessonId, quizScore: scorePercent);
    }

    // 2. Si aprobó, desbloquear siguiente lección
    if (passed && mounted) {
      final lessons = context.read<LessonProvider>().lessons;
      final lesson = lessons.where((l) => l.id == widget.lessonId).firstOrNull;
      if (lesson != null) {
        await context
            .read<LessonProvider>()
            .completeLesson(widget.lessonId, lesson.orderIndex);
      }
    }

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.quizResult,
        arguments: {
          'score': _score,
          'total': total,
          'lessonId': widget.lessonId,
        },
      );
    }
  }
}

// ─── Botón de opción ──────────────────────────────────────────────────────────

class _OptionButton extends StatelessWidget {
  final String option;
  final String text;
  final String? selectedOption;
  final String correctOption;
  final bool answered;
  final VoidCallback? onTap;

  const _OptionButton({
    required this.option, required this.text, required this.selectedOption,
    required this.correctOption, required this.answered, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.lightGray;
    Color bgColor = Colors.white;
    Color textColor = AppColors.textPrimary;

    if (answered) {
      final isCorrect = option == correctOption;
      final isSelected = option == selectedOption;
      if (isCorrect) {
        borderColor = AppColors.secondary;
        bgColor = AppColors.secondary.withOpacity(0.1);
        textColor = AppColors.secondary;
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.error;
        bgColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
      }
    } else if (option == selectedOption) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withOpacity(0.05);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: borderColor.withOpacity(0.15),
              child: Text(option.toUpperCase(),
                  style: TextStyle(color: textColor, fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text,
                style: TextStyle(color: textColor, fontSize: 15))),
            if (answered && option == correctOption)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.secondary, size: 20),
            if (answered && option == selectedOption && option != correctOption)
              const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**
```bash
git add lib/screens/quiz/quiz_screen.dart
git commit -m "feat: quiz triggers completeLesson at ≥70%, shows word image as hint"
```

---

## Task 6: LessonCard Widget — Lock State Visual

**Files:**
- Modify: `lib/widgets/lesson_card.dart`

- [ ] **Step 1: Add lock overlay to LessonCard**

Replace the `build` method's `Card` widget to wrap in a `Stack` with lock overlay:

```dart
  @override
  Widget build(BuildContext context) {
    final completed = lesson.isCompleted || (progress?.completed ?? false);
    final locked = lesson.isLocked;
    final completionValue = _calculateCompletion();

    return Opacity(
      opacity: locked ? 0.55 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Stack(
          children: [
            InkWell(
              onTap: locked ? null : onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _CategoryChip(category: lesson.category),
                        const SizedBox(width: 8),
                        DifficultyIndicator(difficulty: lesson.difficulty),
                        const Spacer(),
                        if (locked)
                          const Icon(Icons.lock_rounded,
                              color: AppColors.textSecondary, size: 20)
                        else if (completed)
                          const Icon(Icons.check_circle,
                              color: AppColors.secondary, size: 20),
                        if (isAdminMode) ...[
                          const SizedBox(width: 4),
                          _AdminMenu(onEdit: onEdit, onDelete: onDelete),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: locked ? AppColors.textSecondary : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locked
                          ? 'Completa la lección anterior para desbloquear'
                          : '$wordCount ${wordCount == 1 ? "palabra" : "palabras"}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: locked ? AppColors.textSecondary : null,
                        fontStyle: locked ? FontStyle.italic : null,
                        fontSize: locked ? 12 : null,
                      ),
                    ),
                    if (lesson.isExample && !locked) ...[
                      const SizedBox(height: 4),
                      Text(
                        '⚠ Contenido de demo — requiere validación por hablante nativo',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          color: AppColors.accent,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: locked ? 0.0 : completionValue,
                        minHeight: 6,
                        backgroundColor: AppColors.lightGray,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completed ? AppColors.secondary : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateCompletion() {
    if (progress == null) return 0.0;
    if (lesson.isCompleted || progress!.completed) return 1.0;
    if (wordCount == 0) return 0.0;
    return (progress!.wordsPracticed / wordCount).clamp(0.0, 1.0);
  }
```

- [ ] **Step 2: Commit**
```bash
git add lib/widgets/lesson_card.dart
git commit -m "feat: LessonCard shows lock icon and disabled state for locked lessons"
```

---

## Task 7: LessonListScreen — Diagnostic Button + Lock Enforcement

**Files:**
- Modify: `lib/screens/lessons/lesson_list_screen.dart`

- [ ] **Step 1: Add diagnostic button to AppBar and disable locked lesson taps**

In `_LessonListScreenState.build()`, update the AppBar `actions` to add diagnostic button:

```dart
      appBar: AppBar(
        title: const Text('Lecciones'),
        actions: [
          // Botón diagnóstico (si no ha sido completado)
          FutureBuilder<bool>(
            future: _isDiagnosticPending(),
            builder: (context, snap) {
              if (snap.data == true) {
                return TextButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.diagnosticExam,
                  ).then((_) {
                    lessonProvider.loadLessons();
                  }),
                  icon: const Icon(Icons.science_outlined,
                      color: Colors.white, size: 18),
                  label: const Text('Diagnóstico',
                      style: TextStyle(color: Colors.white)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: Icon(auth.isAdminMode
                ? Icons.admin_panel_settings
                : Icons.settings_outlined),
            tooltip: auth.isAdminMode ? 'Admin activo' : 'Configuración',
            onPressed: () => Navigator.pushNamed(
              context,
              auth.isAdminMode ? AppRoutes.adminPanel : AppRoutes.settings,
            ),
          ),
        ],
      ),
```

Add this helper method to `_LessonListScreenState`:
```dart
  Future<bool> _isDiagnosticPending() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('diagnosticCompleted') ?? false);
  }
```

Add import at top of file:
```dart
import 'package:shared_preferences/shared_preferences.dart';
```

In `_LessonCardWrapper.build()`, the `onTap` already passes `lesson.isLocked` through `LessonCard` (Task 6 handled disabling `onTap` when locked). No additional change needed here — the `LessonCard` already sets `onTap: locked ? null : onTap`.

- [ ] **Step 2: Commit**
```bash
git add lib/screens/lessons/lesson_list_screen.dart
git commit -m "feat: LessonListScreen shows diagnostic button when exam not yet taken"
```

---

## Task 8: AppRoutes + app.dart — Register Diagnostic Route

**Files:**
- Modify: `lib/core/constants/app_routes.dart`
- Modify: `lib/app.dart`

- [ ] **Step 1: Add route constant**

In `app_routes.dart`, add inside the class:
```dart
  static const String diagnosticExam    = '/diagnostic-exam';
  static const String diagnosticResult  = '/diagnostic-result';
```

- [ ] **Step 2: Register routes in app.dart**

Add imports:
```dart
import 'screens/diagnostic/diagnostic_exam_screen.dart';
import 'screens/diagnostic/diagnostic_result_screen.dart';
```

Add to the static `routes` map:
```dart
AppRoutes.diagnosticExam: (_) => const DiagnosticExamScreen(),
```

Add to `onGenerateRoute` switch:
```dart
case AppRoutes.diagnosticResult:
  final args = settings.arguments as Map<String, dynamic>;
  return MaterialPageRoute(
    builder: (_) => DiagnosticResultScreen(
      results: args['results'] as Map<int, bool>,
      lessonTitles: args['lessonTitles'] as Map<int, String>,
    ),
  );
```

- [ ] **Step 3: Commit**
```bash
git add lib/core/constants/app_routes.dart lib/app.dart
git commit -m "feat: add diagnostic exam/result routes"
```

---

## Task 9: DiagnosticExamScreen (New)

**Files:**
- Create: `lib/screens/diagnostic/diagnostic_exam_screen.dart`

- [ ] **Step 1: Create the screen**

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/models/quiz_question.dart';
import '../../core/repositories/lesson_repository.dart';
import '../../core/repositories/quiz_repository.dart';
import '../../providers/lesson_provider.dart';

/// Examen diagnóstico: 2 preguntas por lección × N lecciones.
/// Resultado: marca como completadas las lecciones aprobadas (respetando secuencia).
class DiagnosticExamScreen extends StatefulWidget {
  const DiagnosticExamScreen({super.key});

  @override
  State<DiagnosticExamScreen> createState() => _DiagnosticExamScreenState();
}

class _DiagnosticExamScreenState extends State<DiagnosticExamScreen> {
  List<_DiagnosticQuestion> _questions = [];
  int _currentIndex = 0;
  String? _selectedOption;
  bool _answered = false;
  bool _loading = true;

  // lessonId → correct count (0, 1, or 2)
  final Map<int, int> _correctPerLesson = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final lessonRepo = LessonRepository();
    final quizRepo = QuizRepository();
    final lessons = await lessonRepo.getLessonsOrdered();
    final rng = Random();
    final all = <_DiagnosticQuestion>[];

    for (final lesson in lessons) {
      final qs = await quizRepo.getQuestionsByLesson(lesson.id!);
      if (qs.isEmpty) continue;
      qs.shuffle(rng);
      final selected = qs.take(2);
      for (final q in selected) {
        all.add(_DiagnosticQuestion(lessonId: lesson.id!, lessonTitle: lesson.title, q: q));
      }
    }

    all.shuffle(rng);
    setState(() {
      _questions = all;
      _loading = false;
    });
  }

  void _selectOption(String option) {
    final dq = _questions[_currentIndex];
    final correct = dq.q.isCorrect(option);
    if (correct) {
      _correctPerLesson[dq.lessonId] = (_correctPerLesson[dq.lessonId] ?? 0) + 1;
    } else {
      _correctPerLesson.putIfAbsent(dq.lessonId, () => 0);
    }
    setState(() {
      _selectedOption = option;
      _answered = true;
    });
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    // Determine which lessons passed (≥1/2 correct), respecting sequence
    final lessonRepo = LessonRepository();
    final lessons = await lessonRepo.getLessonsOrdered();

    // Sequential rule: if lesson N fails, lessons N+1..12 stay locked even if passed
    final toUnlock = <int>[];
    final results = <int, bool>{};
    final titles = <int, String>{};

    for (final lesson in lessons) {
      final correct = _correctPerLesson[lesson.id] ?? 0;
      final passed = correct >= 1;
      titles[lesson.id!] = lesson.title;

      if (!passed) {
        // This lesson fails → stop chain
        results[lesson.id!] = false;
        // Mark remaining as failed (not unlocked)
        for (final remaining in lessons) {
          if (!results.containsKey(remaining.id)) {
            results[remaining.id!] = false;
          }
        }
        break;
      }
      results[lesson.id!] = true;
      toUnlock.add(lesson.id!);
    }

    // Apply unlocks
    if (toUnlock.isNotEmpty) {
      await lessonRepo.unlockLessons(toUnlock);
    }

    // Mark diagnostic as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('diagnosticCompleted', true);

    // Refresh lessons in provider
    if (mounted) {
      await context.read<LessonProvider>().loadLessons();
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.diagnosticResult,
        arguments: {'results': results, 'lessonTitles': titles},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diagnóstico de nivel')),
        body: const Center(child: Text('No hay preguntas disponibles.')),
      );
    }

    final total = _questions.length;
    final dq = _questions[_currentIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final exit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('¿Cancelar diagnóstico?'),
            content: const Text('Si cancelas, empezarás desde la Lección 1.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Continuar')),
              TextButton(onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Cancelar examen',
                      style: TextStyle(color: AppColors.error))),
            ],
          ),
        );
        if (exit == true && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Diagnóstico ${_currentIndex + 1}/$total'),
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / total,
              backgroundColor: AppColors.primary.withOpacity(0.3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tema de la pregunta
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Tema: ${dq.lessonTitle}',
                  style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 16),
              Text(dq.q.question,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              ...['a', 'b', 'c', 'd'].map((opt) => _DiagOption(
                    option: opt,
                    text: dq.q.getOptionText(opt),
                    selectedOption: _selectedOption,
                    correctOption: dq.q.correctOption,
                    answered: _answered,
                    onTap: _answered ? null : () => _selectOption(opt),
                  )),
              const Spacer(),
              if (_answered)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    child: Text(_currentIndex < total - 1
                        ? 'Siguiente'
                        : 'Ver resultados'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiagnosticQuestion {
  final int lessonId;
  final String lessonTitle;
  final QuizQuestion q;
  _DiagnosticQuestion({required this.lessonId, required this.lessonTitle, required this.q});
}

class _DiagOption extends StatelessWidget {
  final String option, text;
  final String? selectedOption;
  final String correctOption;
  final bool answered;
  final VoidCallback? onTap;

  const _DiagOption({
    required this.option, required this.text, required this.selectedOption,
    required this.correctOption, required this.answered, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.lightGray;
    Color bgColor = Colors.white;
    Color textColor = AppColors.textPrimary;

    if (answered) {
      if (option == correctOption) {
        borderColor = AppColors.secondary;
        bgColor = AppColors.secondary.withOpacity(0.1);
        textColor = AppColors.secondary;
      } else if (option == selectedOption) {
        borderColor = AppColors.error;
        bgColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
      }
    } else if (option == selectedOption) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withOpacity(0.05);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: borderColor.withOpacity(0.15),
              child: Text(option.toUpperCase(),
                  style: TextStyle(color: textColor, fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text,
                style: TextStyle(color: textColor, fontSize: 15))),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**
```bash
git add lib/screens/diagnostic/diagnostic_exam_screen.dart
git commit -m "feat: add DiagnosticExamScreen with 2 questions per lesson, sequential unlock"
```

---

## Task 10: DiagnosticResultScreen (New)

**Files:**
- Create: `lib/screens/diagnostic/diagnostic_result_screen.dart`

- [ ] **Step 1: Create the screen**

```dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

/// Shows diagnostic results: which lessons were unlocked, which to learn.
class DiagnosticResultScreen extends StatelessWidget {
  final Map<int, bool> results;       // lessonId → passed?
  final Map<int, String> lessonTitles; // lessonId → title

  const DiagnosticResultScreen({
    super.key,
    required this.results,
    required this.lessonTitles,
  });

  @override
  Widget build(BuildContext context) {
    final passed = results.values.where((v) => v).length;
    final total = results.length;

    // Sort by lessonId to maintain order
    final sorted = results.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu nivel en Ngigua'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Header con puntaje
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              children: [
                Text(
                  passed == total ? '🎉' : passed > 0 ? '🌟' : '📚',
                  style: const TextStyle(fontSize: 56),
                ),
                const SizedBox(height: 12),
                Text(
                  'Conoces $passed de $total temas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  passed == total
                      ? '¡Excelente! Todas las lecciones están disponibles.'
                      : passed > 0
                          ? 'Las lecciones desbloqueadas están listas para ti.'
                          : 'Empieza desde el principio. ¡Tú puedes!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.85)),
                ),
              ],
            ),
          ),
          // Lista de resultados
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final entry = sorted[index];
                final lessonPassed = entry.value;
                final title = lessonTitles[entry.key] ?? 'Lección ${index + 1}';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: lessonPassed
                        ? AppColors.secondary.withOpacity(0.15)
                        : AppColors.lightGray,
                    child: Icon(
                      lessonPassed
                          ? Icons.check_circle_rounded
                          : Icons.lock_rounded,
                      color: lessonPassed
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: lessonPassed
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  subtitle: Text(
                    lessonPassed ? 'Desbloqueada ✓' : 'Por aprender',
                    style: TextStyle(
                      color: lessonPassed
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          // Botón para ir al inicio
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                ),
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Ir a mis lecciones'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**
```bash
git add lib/screens/diagnostic/diagnostic_result_screen.dart
git commit -m "feat: add DiagnosticResultScreen"
```

---

## Task 11: SettingsScreen — Reset Diagnostic

**Files:**
- Modify: `lib/screens/settings/settings_screen.dart`

- [ ] **Step 1: Add reset diagnostic list tile**

Add this import at the top:
```dart
import 'package:shared_preferences/shared_preferences.dart';
```

Add a new section after the Admin divider, before the "Acerca de" divider:

```dart
          const Divider(),
          _SectionHeader(title: 'Diagnóstico'),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0x1AB5622A),
              child: Icon(Icons.science_outlined, color: AppColors.primary),
            ),
            title: const Text('Reiniciar diagnóstico de nivel'),
            subtitle: const Text(
                'Vuelve a hacer el examen diagnóstico para actualizar tu nivel.'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _resetDiagnostic(context),
          ),
```

Add the reset method to `SettingsScreen`:
```dart
  Future<void> _resetDiagnostic(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reiniciar diagnóstico'),
        content: const Text(
            '¿Reiniciar el examen diagnóstico? Tu progreso en las lecciones se mantiene.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('diagnosticCompleted', false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diagnóstico reiniciado. Ve a Lecciones para hacerlo.'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    }
  }
```

- [ ] **Step 2: Commit**
```bash
git add lib/screens/settings/settings_screen.dart
git commit -m "feat: settings screen adds reset diagnostic option"
```

---

## Task 12: Database Seeder — Full A1 Expansion

**Files:**
- Modify: `lib/core/database/database_seeder.dart`

- [ ] **Step 1: Replace the entire seeder**

> **Note on vocabulary:** Words for lessons 6–12 are extracted from
> *Gramática Ngigua de San Marcos Tlacoyalco* (Sharon Stark Campbell,
> Instituto Lingüístico de Verano, A.C.) and *Vocabulario Diccionario
> Ngiigua* (UNTI A.C., 2016). All content must be validated by native
> speakers before the official presentation.

```dart
import '../database/database_helper.dart';

/// Carga datos iniciales en la base de datos en el primer lanzamiento.
///
/// Vocabulario Ngigua de San Marcos Tlacoyalco, Puebla.
/// Fuentes:
///  - "Vocabulario Diccionario Ngiigua" — Sharon Stark Campbell,
///    Jacob Luna Hernández, Verónica Luna Villanueva. UNTI A.C., 2016.
///  - "Gramática Ngigua de San Marcos Tlacoyalco" — Sharon Stark Campbell,
///    Instituto Lingüístico de Verano, A.C.
///
/// ⚠ El contenido debe ser validado por hablantes nativos de la comunidad.
class DatabaseSeeder {
  static Future<void> seed() async {
    final db = DatabaseHelper.instance;
    final now = DateTime.now().toIso8601String();

    // ── LECCIÓN 1: Saludos básicos ────────────────────────────────────────────
    final l1 = await db.insert('lessons', {
      'title': 'Saludos básicos',
      'description':
          'Aprende a saludar y expresar bienestar en Ngigua. '
          'Los saludos son la puerta de entrada a cualquier conversación.',
      'category': 'Saludos', 'difficulty': 1, 'created_at': now,
      'is_example': 1, 'order_index': 1, 'is_locked': 0, 'is_completed': 0,
    });

    for (final s in [
      ('deo',    'Saludo al encontrar a alguien', 'assets/images/saludo_deo.jpg',    'Deo — se dice al cruzarse con alguien en el camino'),
      ('jian',   'Bien / Bueno',                  'assets/images/saludo_jian.jpg',   'Jian — estoy bien'),
      ('jaro',   'Bonito / De buen carácter',     'assets/images/saludo_jaro.jpg',   'Chrjuin — bonito (sinónimo de jaro)'),
      ('chee',   'Estar alegre / contento',        'assets/images/saludo_chee.jpg',   'Chéna — yo estoy alegre'),
      ('juajna', 'Saludo / Mensaje',               'assets/images/saludo_juajna.jpg', 'Juajna — para enviar un saludo o mensaje'),
    ]) {
      await db.insert('words', {
        'lesson_id': l1, 'indigenous_word': s.$1, 'translation': s.$2,
        'audio_path': null, 'image_path': s.$3, 'example_phrase': s.$4,
      });
    }

    for (final q in [
      ('¿Cómo se saluda al encontrar a alguien en Ngigua?', 'deo', 'jian', 'chee', 'juajna', 'a'),
      ('¿Qué significa "jian" en Ngigua?', 'Triste', 'Bien / Bueno', 'Saludo', 'Familia', 'b'),
      ('"chee" en Ngigua significa:', 'Estar cansado', 'Estar enojado', 'Estar alegre / contento', 'Estar enfermo', 'c'),
      ('¿Cuál de estas palabras significa "Bonito / De buen carácter"?', 'juajna', 'jian', 'jaro', 'deo', 'c'),
      ('¿Qué significa "juajna" en Ngigua?', 'Despedida', 'Saludo / Mensaje', 'Tristeza', 'Enfermedad', 'b'),
      ('"jaro" describe a alguien que es:', 'Enojón', 'Perezoso', 'Bonito / De buen carácter', 'Triste', 'c'),
      ('¿Qué palabra usas para saludar al cruzarte con alguien?', 'chee', 'jian', 'deo', 'jaro', 'c'),
      ('¿Cuál de estas palabras NO es un saludo en Ngigua?', 'deo', 'juajna', 'nii', 'jian', 'c'),
      ('Para decir "Yo estoy alegre" en Ngigua se dice:', 'jian', 'chéna', 'deo', 'jaro', 'b'),
      ('¿Qué significa "deo" en Ngigua?', 'Familia', 'Número uno', 'Saludo al encontrar a alguien', 'Color rojo', 'c'),
      ('"Chéna" usa la raíz "chee" que significa:', 'Tristeza', 'Alegría / Contento', 'Enojo', 'Cansancio', 'b'),
      ('¿Cómo responderías si alguien te pregunta "¿jian?" (¿estás bien?)?', 'deo', 'jaro', 'jian', 'nii', 'c'),
    ]) {
      await db.insert('quiz_questions', {
        'lesson_id': l1, 'question': q.$1, 'option_a': q.$2,
        'option_b': q.$3, 'option_c': q.$4, 'option_d': q.$5, 'correct_opt': q.$6,
      });
    }

    // ── LECCIÓN 2: Números del 1 al 5 ────────────────────────────────────────
    final l2 = await db.insert('lessons', {
      'title': 'Números del 1 al 5',
      'description':
          'Aprende a contar del 1 al 5 en Ngigua. '
          'El sistema es vigesimal (base 20): "kan" = veinte.',
      'category': 'Números', 'difficulty': 1, 'created_at': now,
      'is_example': 1, 'order_index': 2, 'is_locked': 1, 'is_completed': 0,
    });

    for (final n in [
      ('jngo', 'Uno (1)',    'assets/images/numero_jngo.jpg', 'jngo nchian — una casa'),
      ('yoo',  'Dos (2)',    'assets/images/numero_yoo.jpg',  'raa ra yoo — tiene dos manos'),
      ('nii',  'Tres (3)',   'assets/images/numero_nii.jpg',  'nio ra nii — tres tortillas'),
      ('noo',  'Cuatro (4)', 'assets/images/numero_noo.jpg',  'thukma ra noo — cuatro papas'),
      ('nao',  'Cinco (5)',  'assets/images/numero_nao.jpg',  'nao kan — cien (cinco veintes)'),
    ]) {
      await db.insert('words', {
        'lesson_id': l2, 'indigenous_word': n.$1, 'translation': n.$2,
        'audio_path': null, 'image_path': n.$3, 'example_phrase': n.$4,
      });
    }

    for (final q in [
      ('¿Cómo se dice "Uno" en Ngigua?', 'yoo', 'nao', 'jngo', 'nii', 'c'),
      ('"noo" es el número:', 'Tres', 'Cuatro', 'Cinco', 'Dos', 'b'),
      ('¿Cómo se dice "Dos" en Ngigua?', 'nii', 'yoo', 'noo', 'jngo', 'b'),
      ('¿Cómo se dice "Tres" en Ngigua?', 'yoo', 'nao', 'noo', 'nii', 'd'),
      ('¿Cómo se dice "Cinco" en Ngigua?', 'noo', 'nii', 'nao', 'jngo', 'c'),
      ('¿Qué número es "yoo"?', 'Uno', 'Dos', 'Tres', 'Cuatro', 'b'),
      ('¿Qué número es "nao"?', 'Dos', 'Tres', 'Cuatro', 'Cinco', 'd'),
      ('Ordena: ¿cuál viene después de "yoo" (dos)?', 'jngo', 'noo', 'nii', 'nao', 'c'),
      ('¿Cuál de estos NO es un número del 1 al 5?', 'jngo', 'yoo', 'deo', 'nii', 'c'),
      ('En el sistema vigesimal Ngigua, ¿cuánto es "kan"?', 'Diez', 'Quince', 'Veinte', 'Cien', 'c'),
      ('¿Cuánto es jngo + jngo en Ngigua?', 'jngo', 'yoo', 'nii', 'noo', 'b'),
      ('¿Qué significa "nao kan"?', 'Cinco', 'Veinte', 'Cien', 'Cincuenta', 'c'),
    ]) {
      await db.insert('quiz_questions', {
        'lesson_id': l2, 'question': q.$1, 'option_a': q.$2,
        'option_b': q.$3, 'option_c': q.$4, 'option_d': q.$5, 'correct_opt': q.$6,
      });
    }

    // ── LECCIÓN 3: Colores ────────────────────────────────────────────────────
    final l3 = await db.insert('lessons', {
      'title': 'Colores',
      'description': 'Aprende los colores básicos en Ngigua.',
      'category': 'Vocabulario', 'difficulty': 2, 'created_at': now,
      'is_example': 1, 'order_index': 3, 'is_locked': 1, 'is_completed': 0,
    });

    for (final c in [
      ('jatse', 'Rojo / Colorado', 'assets/images/color_jatse.jpg', 'ndaxra jatse — mole (lit. salsa roja)'),
      ('yua',   'Verde / Azul',    'assets/images/color_yua.jpg',   'jnayua — chile verde'),
      ('rua',   'Blanco / Limpio', 'assets/images/color_rua.jpg',   'nuxra rua — cobija blanca'),
      ('sine',  'Amarillo',        'assets/images/color_sine.jpg',  'nchaon sine — sol amarillo'),
      ('thie',  'Negro / Noche',   'assets/images/color_thie.jpg',  'thie ra nchaon — la noche (negra como el sol que no está)'),
    ]) {
      await db.insert('words', {
        'lesson_id': l3, 'indigenous_word': c.$1, 'translation': c.$2,
        'audio_path': null, 'image_path': c.$3, 'example_phrase': c.$4,
      });
    }

    for (final q in [
      ('¿Qué color es "jatse" en Ngigua?', 'Azul', 'Amarillo', 'Verde', 'Rojo', 'd'),
      ('"rua" significa:', 'Negro', 'Blanco / Limpio', 'Rojo', 'Verde', 'b'),
      ('¿Qué color es "thie"?', 'Rojo', 'Amarillo', 'Blanco', 'Negro / Noche', 'd'),
      ('¿Qué color es "yua"?', 'Rojo', 'Negro', 'Verde / Azul', 'Amarillo', 'c'),
      ('¿Qué color es "sine"?', 'Blanco', 'Rojo', 'Negro', 'Amarillo', 'd'),
      ('"ndaxra jatse" significa:', 'Chile verde', 'Mole colorado', 'Cielo azul', 'Sol amarillo', 'b'),
      ('En Ngigua, el color del cielo o la hierba es:', 'jatse', 'thie', 'yua', 'rua', 'c'),
      ('"jnayua" significa:', 'Mole rojo', 'Maíz amarillo', 'Chile verde', 'Noche negra', 'c'),
      ('¿Cuál de estos colores es opuesto al negro?', 'jatse', 'sine', 'yua', 'rua', 'd'),
      ('¿Cuál de estas palabras significa "rojo"?', 'thie', 'rua', 'jatse', 'yua', 'c'),
      ('"nuxra rua" significa:', 'Cobija negra', 'Cobija blanca', 'Cobija roja', 'Cobija verde', 'b'),
      ('¿Cuál es el color del sol (amarillo) en Ngigua?', 'thie', 'rua', 'jatse', 'sine', 'd'),
    ]) {
      await db.insert('quiz_questions', {
        'lesson_id': l3, 'question': q.$1, 'option_a': q.$2,
        'option_b': q.$3, 'option_c': q.$4, 'option_d': q.$5, 'correct_opt': q.$6,
      });
    }

    // ── LECCIÓN 4: Animales ───────────────────────────────────────────────────
    final l4 = await db.insert('lessons', {
      'title': 'Animales del entorno',
      'description':
          'Conoce cómo se llaman los animales en Ngigua. '
          'La palabra general para animal es "kuxiigo". '
          'Nota el prefijo "ku-" presente en muchos animales.',
      'category': 'Animales', 'difficulty': 2, 'created_at': now,
      'is_example': 1, 'order_index': 4, 'is_locked': 1, 'is_completed': 0,
    });

    for (final a in [
      ('kunia',    'Perro',    'assets/images/animal_perro.jpg',     'kunia thie — perro negro'),
      ('kumichin', 'Gato',     'assets/images/animal_gato.jpg',      'kumichin rua — gato blanco'),
      ('kuxijna',  'Venado',   'assets/images/animal_venado.jpg',    'kuxijna ra yoo — dos venados'),
      ('kunthua',  'Pájaro',   'assets/images/animal_pajaro.jpg',    'kunthua jatse — pájaro colorado'),
      ('kukapio',  'Mariposa', 'assets/images/animal_mariposa.jpg',  'kukapio rua — mariposa blanca'),
    ]) {
      await db.insert('words', {
        'lesson_id': l4, 'indigenous_word': a.$1, 'translation': a.$2,
        'audio_path': null, 'image_path': a.$3, 'example_phrase': a.$4,
      });
    }

    for (final q in [
      ('¿Cómo se dice "Perro" en Ngigua?', 'kumichin', 'kuxijna', 'kunia', 'kunthua', 'c'),
      ('¿Cómo se dice "Gato" en Ngigua?', 'kunia', 'kumichin', 'kukapio', 'kuxijna', 'b'),
      ('¿Cómo se dice "Venado" en Ngigua?', 'kunthua', 'kunia', 'kuxijna', 'kukapio', 'c'),
      ('¿Cómo se dice "Pájaro" en Ngigua?', 'kukapio', 'kunthua', 'kunia', 'kumichin', 'b'),
      ('¿Cómo se dice "Mariposa" en Ngigua?', 'kuxijna', 'kumichin', 'kunia', 'kukapio', 'd'),
      ('¿Qué animal es "kumichin"?', 'Perro', 'Venado', 'Gato', 'Pájaro', 'c'),
      ('¿Qué animal es "kuxijna"?', 'Mariposa', 'Venado', 'Gato', 'Pájaro', 'b'),
      ('¿Qué animal es "kunthua"?', 'Perro', 'Gato', 'Venado', 'Pájaro', 'd'),
      ('¿Qué significa el prefijo "ku-" en muchos animales Ngigua?', 'Color', 'Animal (marcador)', 'Grande', 'Pequeño', 'b'),
      ('La palabra general para "animal" en Ngigua es:', 'kukapio', 'kuxijna', 'kuxiigo', 'kunthua', 'c'),
      ('¿Cuál de estos NO es un animal?', 'kunia', 'kunthua', 'jatse', 'kukapio', 'c'),
      ('"kukapio rua" significa:', 'Perro blanco', 'Venado blanco', 'Mariposa blanca', 'Pájaro blanco', 'c'),
    ]) {
      await db.insert('quiz_questions', {
        'lesson_id': l4, 'question': q.$1, 'option_a': q.$2,
        'option_b': q.$3, 'option_c': q.$4, 'option_d': q.$5, 'correct_opt': q.$6,
      });
    }

    // ── LECCIÓN 5: La familia ─────────────────────────────────────────────────
    final l5 = await db.insert('lessons', {
      'title': 'La familia',
      'description':
          'Aprende los términos de parentesco en Ngigua. '
          'La familia ("nichoo") es el núcleo de la organización social '
          'de San Marcos Tlacoyalco.',
      'category': 'Familia', 'difficulty': 3, 'created_at': now,
      'is_example': 1, 'order_index': 5, 'is_locked': 1, 'is_completed': 0,
    });

    for (final f in [
      ('ndudaa',   'Padre / Papá',               'assets/images/familia_ndudaa.jpg',   'ndudaa ra jngo — un padre'),
      ('jannaa',   'Madre / Mamá',               'assets/images/familia_jannaa.jpg',   'jannaa ra jngo — una madre'),
      ('choo',     'Hermano / Hermana',           'assets/images/familia_choo.jpg',     'choo ra yoo — dos hermanos'),
      ('nichoo',   'Familia',                     'assets/images/familia_nichoo.jpg',   'nichoo ra jngo — una familia'),
      ('junchjan', 'Anciano / Anciana (respeto)', 'assets/images/familia_junchjan.jpg', 'junchjan ra jngo — un anciano sabio'),
    ]) {
      await db.insert('words', {
        'lesson_id': l5, 'indigenous_word': f.$1, 'translation': f.$2,
        'audio_path': null, 'image_path': f.$3, 'example_phrase': f.$4,
      });
    }

    for (final q in [
      ('"jannaa" en Ngigua significa:', 'Padre', 'Abuelo', 'Madre / Mamá', 'Hermano', 'c'),
      ('¿Cómo se dice "Padre/Papá" en Ngigua?', 'jannaa', 'choo', 'ndudaa', 'nichoo', 'c'),
      ('¿Cómo se dice "Hermano / Hermana" en Ngigua?', 'ndudaa', 'jannaa', 'junchjan', 'choo', 'd'),
      ('¿Qué significa "nichoo"?', 'Hermano', 'Padre', 'Familia', 'Anciano', 'c'),
      ('¿Qué significa "junchjan"?', 'Niño', 'Padre', 'Hermano', 'Anciano / Anciana (respeto)', 'd'),
      ('¿Qué miembro de la familia es "jannaa"?', 'El padre', 'La hermana', 'La madre', 'El abuelo', 'c'),
      ('¿Qué miembro de la familia es "ndudaa"?', 'La madre', 'El padre', 'El hermano', 'El anciano', 'b'),
      ('La palabra "nichoo" incluye a:', 'Solo los padres', 'Solo los hermanos', 'Toda la familia', 'Solo los abuelos', 'c'),
      ('"junchjan" se usa para referirse a:', 'Niños pequeños', 'Personas mayores con respeto', 'Hermanos mayores', 'Padres jóvenes', 'b'),
      ('"choo ra yoo" significa:', 'Dos padres', 'Dos madres', 'Dos hermanos', 'Dos familias', 'c'),
      ('¿Cuál de estos NO es un término de familia?', 'ndudaa', 'jannaa', 'jatse', 'choo', 'c'),
      ('En Ngigua, "nichoo" representa:', 'El trabajo', 'La milpa', 'La familia (núcleo social)', 'El saludo', 'c'),
    ]) {
      await db.insert('quiz_questions', {
        'lesson_id': l5, 'question': q.$1, 'option_a': q.$2,
        'option_b': q.$3, 'option_c': q.$4, 'option_d': q.$5, 'correct_opt': q.$6,
      });
    }

    // ── LECCIÓN 6: El cuerpo humano ───────────────────────────────────────────
    // Fuente: Gramática Ngigua (Sharon Stark Campbell, ILV) — Apéndice I
    final l6 = await db.insert('lessons', {
      'title': 'El cuerpo humano',
      'description':
          'Aprende las partes del cuerpo en Ngigua. '
          '"jaa" es la cabeza, "raa" es el brazo o la mano.',
      'category': 'Cuerpo', 'difficulty': 2, 'created_at': now,
      'is_example': 1, 'order_index': 6, 'is_locked': 1, 'is_completed': 0,
    });

    for (final c in [
      ('jaa',       'Cabeza',      'assets/images/cuerpo_jaa.jpg',       'jaa ra jngo — tiene una cabeza'),
      ('jmakón',    'Ojo / Ojos',  'assets/images/cuerpo_jmakon.jpg',    'bikón xin jmakón — vio con sus ojos'),
      ('chinthjón', 'Nariz',       'assets/images/cuerpo_chintmjon.jpg', 'chinthjón ra jngo — tiene una nariz'),
      ('rua',       'Boca',        'assets/images/cuerpo_rua.jpg',       'rua ra jngo — tiene una boca'),
      ('raa',       'Mano / Brazo','assets/images/cuerpo_raa.jpg',       'raa ra yoo — tiene dos manos'),
      ('ruthea',    'Pie / Pierna','assets/images/cuerpo_ruthea.jpg',    'ruthea ra yoo — tiene dos pies'),
      ('neje',      'Lengua',      'assets/images/cuerpo_neje.jpg',      'neje ra jngo — tiene una lengua'),
      ('thusin',    'Cuello',      'assets/images/cuerpo_thusin.jpg',    'thusin ra jngo — tiene un cuello'),
    ]) {
      await db.insert('words', {
        'lesson_id': l6, 'indigenous_word': c.$1, 'translation': c.$2,
        'audio_path': null, 'image_path': c.$3, 'example_phrase': c.$4,
      });
    }

    for (final q in [
      ('¿Cómo se dice "cabeza" en Ngigua?', 'raa', 'neje', 'jaa', 'thusin', 'c'),
      ('¿Qué parte del cuerpo es "jmakón"?', 'Nariz', 'Ojo / Ojos', 'Lengua', 'Cuello', 'b'),
      ('"chinthjón" en Ngigua significa:', 'Ojo', 'Boca', 'Nariz', 'Oreja', 'c'),
      ('¿Cómo se dice "mano" o "brazo" en Ngigua?', 'ruthea', 'neje', 'raa', 'jmakón', 'c'),
      ('"ruthea" se refiere a:', 'La mano', 'El cuello', 'El pie / la pierna', 'La nariz', 'c'),
      ('¿Qué parte del cuerpo es "neje"?', 'Cuello', 'Boca', 'Nariz', 'Lengua', 'd'),
      ('¿Cómo se dice "cuello" en Ngigua?', 'raa', 'neje', 'jaa', 'thusin', 'd'),
      ('"rua" en el cuerpo humano significa:', 'Cabeza', 'Ojo', 'Boca', 'Nariz', 'c'),
      ('"jaa" se refiere a la parte más alta del cuerpo. ¿Cuál es?', 'Cuello', 'Cabeza', 'Nariz', 'Ojo', 'b'),
      ('¿Cuál de estos NO es una parte del cuerpo?', 'jaa', 'raa', 'jatse', 'thusin', 'c'),
      ('Para decir "tiene dos manos": "raa ra ___"', 'jngo', 'yoo', 'nii', 'noo', 'b'),
      ('"bikón xin jmakón" significa:', 'Habló con la boca', 'Vio con sus ojos', 'Escuchó con sus oídos', 'Corrió con sus pies', 'b'),
    ]) {
      await db.insert('quiz_questions', {
        'lesson_id': l6, 'question': q.$1, 'option_a': q.$2,
        'option_b': q.$3, 'option_c': q.$4, 'option_d': q.$5, 'correct_opt': q.$6,
      });
    }

    // ── LECCIÓN 7: Alimentos y bebidas ────────────────────────────────────────
    final l7 = await db.insert('lessons', {
      'title': 'Alimentos y bebidas',
      'description':
          'Aprende los nombres de los alimentos básicos en Ngigua. '
          '"nio" es la tortilla, base de la alimentación en San Marcos.',
      'category': 'Alimentos', 'difficulty': 2, 'created_at': now,
      'is_example': 1, 'order_index': 7, 'is_locked': 1, 'is_completed': 0,
    });

    for (final a in [
      ('nio',       'Tortilla',         'assets/images/alimento_nio.jpg',       'nio ra nii — tres tortillas'),
      ('nua',       'Maíz / Grano',     'assets/images/alimento_nua.jpg',       'nua ra tsje — mucho maíz en la milpa'),
      ('niunthaon', 'Tamal',            'assets/images/alimento_niunthaon.jpg', 'niunthaon jatse — tamal de chile colorado'),
      ('thukma',    'Papa',             'assets/images/alimento_thukma.jpg',    'ndaxra thukma — guisado de papa'),
      ('thuchmoin', 'Fruta',            'assets/images/alimento_thuchmoin.jpg', 'thuchmoin rua — fruta blanca (jícama)'),
      ('ndaxra',    'Comida / Guisado', 'assets/images/alimento_ndaxra.jpg',    'ndaxra jatse — mole colorado'),
      ('tumi',      'Dinero',           'assets/images/alimento_tumi.jpg',      'tumi ra tsje — mucho dinero (cuesta mucho)'),
    ]) {
      await db.insert('words', {
        'lesson_id': l7, 'indigenous_word': a.$1, 'translation': a.$2,
        'audio_path': null, 'image_path': a.$3, 'example_phrase': a.$4,
      });
    }

    for (final q in [
      ('¿Cómo se dice "tortilla" en Ngigua?', 'niunthaon', 'nua', 'nio', 'ndaxra', 'c'),
      ('"nua" en Ngigua significa:', 'Tamal', 'Maíz / Grano', 'Tortilla', 'Dinero', 'b'),
      ('¿Cómo se dice "tamal" en Ngigua?', 'nua', 'nio', 'thukma', 'niunthaon', 'd'),
      ('"thukma" significa:', 'Fruta', 'Maíz', 'Papa', 'Tortilla', 'c'),
      ('¿Cómo se dice "fruta" en Ngigua?', 'thukma', 'ndaxra', 'thuchmoin', 'tumi', 'c'),
      ('"ndaxra" significa:', 'Agua', 'Papa', 'Fruta', 'Comida / Guisado', 'd'),
      ('¿Cómo se dice "dinero" en Ngigua?', 'ndaxra', 'tumi', 'niunthaon', 'nua', 'b'),
      ('"ndaxra jatse" significa:', 'Tamal colorado', 'Mole (guisado rojo)', 'Maíz rojo', 'Fruta roja', 'b'),
      ('¿Cuál de estos NO es un alimento?', 'nio', 'nua', 'thukma', 'tumi', 'd'),
      ('La base de la alimentación en San Marcos Tlacoyalco es:', 'thukma', 'nua', 'thuchmoin', 'ndaxra', 'b'),
      ('"thuchmoin rua" significaría:', 'Papa blanca', 'Fruta blanca', 'Tamal blanco', 'Guisado blanco', 'b'),
      ('"niunthaon jatse" es:', 'Tortilla roja', 'Tamal de chile colorado', 'Maíz rojo', 'Papa colorada', 'b'),
    ]) {
      await db.insert('quiz_questions', {
        'lesson_id': l7, 'question': q.$1, 'option_a': q.$2,
        'option_b': q.$3, 'option_c': q.$4, 'option_d': q.$5, 'correct_opt': q.$6,
      });
    }

    // ── LECCIÓN 8: Verbos básicos ─────────────────────────────────────────────
    final l8 = await db.insert('lessons', {
      'title': 'Verbos básicos',
      'description':
          'Aprende los verbos más usados en Ngigua. '
          '"nichma" es hablar, "thji" es ir.',
      'category': 'Verbos', 'difficulty': 3, 'created_at': now,
      'is_example': 1, 'order_index': 8, 'is_locked': 1, 'is_completed': 0,
    });

    for (final v in [
      ('nichma',  'Hablar',           'assets/images/verbo_nichma.jpg',  'nichma Ngigua — hablar Ngigua'),
      ('thji',    'Ir / Caminar',     'assets/images/verbo_thji.jpg',    'thji nthia — ir allá'),
      ('thii',    'Venir / Llegar',   'assets/images/verbo_thii.jpg',    'thii nthii — venir aquí'),
      ('tsjee',   'Mirar / Ver',      'assets/images/verbo_tsjee.jpg',   'tsjee nthii — mira aquí'),
      ('thjen',   'Lavar',            'assets/images/verbo_thjen.jpg',   'thjen raa — lavar las manos'),
      ('tsmjan',  'Reír',             'assets/images/verbo_tsmjan.jpg',  'tsmjan tsje — reír mucho'),
      ('tsmjang', 'Llorar',           'assets/images/verbo_tsmjang.jpg', 'tsmjang ra jngo — llora mucho'),
      ('ruchrin', 'Brincar / Saltar', 'assets/images/verbo_ruchrin.jpg', 'ruchrin ra tsje — brincar mucho'),
    ]) {
      await db.insert('words', {
        'lesson_id': l8, 'indigenous_word': v.$1, 'translation': v.$2,
        'audio_path': null, 'image_path': v.$3, 'example_phrase': v.$4,
      });
    }

    for (final q in [
      ('¿Cómo se dice "hablar" en Ngigua?', 'thji', 'tsjee', 'nichma', 'thii', 'c'),
      ('"thji" en Ngigua significa:', 'Venir', 'Ir / Caminar', 'Hablar', 'Mirar', 'b'),
      ('¿Cómo se dice "venir" o "llegar" en Ngigua?', 'thji', 'thii', 'tsjee', 'thjen', 'b'),
      ('"tsjee" significa:', 'Lavar', 'Reír', 'Llorar', 'Mirar / Ver', 'd'),
      ('¿Cómo se dice "lavar" en Ngigua?', 'tsjee', 'tsmjan', 'thjen', 'thii', 'c'),
      ('"tsmjan" en Ngigua significa:', 'Llorar', 'Reír', 'Hablar', 'Lavar', 'b'),
      ('¿Cómo se dice "brincar" en Ngigua?', 'nichma', 'ruchrin', 'thji', 'thjen', 'b'),
      ('"ruchrin" significa:', 'Hablar', 'Ir', 'Brincar / Saltar', 'Mirar', 'c'),
      ('¿Cuál de estos verbos indica movimiento de un lugar a otro?', 'tsjee', 'thjen', 'thji', 'tsmjan', 'c'),
      ('"tsjee nthii" significa:', 'Hablar aquí', 'Ir aquí', 'Mira aquí', 'Lavar aquí', 'c'),
      ('"nichma Ngigua" significa:', 'Aprender Ngigua', 'Hablar Ngigua', 'Escuchar Ngigua', 'Ver Ngigua', 'b'),
      ('"tsmjang" y "tsmjan" son antónimos (opuestos). ¿Qué son?', 'Ir y venir', 'Llorar y reír', 'Lavar y ensuciar', 'Hablar y escuchar', 'b'),
    ]) {
      await db.insert('quiz_questions', {
        'lesson_id': l8, 'question': q.$1, 'option_a': q.$2,
        'option_b': q.$3, 'option_c': q.$4, 'option_d': q.$5, 'correct_opt': q.$6,
      });
    }

    // ── LECCIÓN 9: La casa y sus objetos ──────────────────────────────────────
    final l9 = await db.insert('lessons', {
      'title': 'La casa y sus objetos',
      'description':
          'Aprende cómo se llaman la casa y los objetos del hogar en Ngigua. '
          '"nchian" es la casa, "xrui" es el fuego o fogón.',
      'category': 'Casa', 'difficulty': 3, 'created_at': now,
      'is_example': 1, 'order_index': 9, 'is_locked': 1, 'is_completed': 0,
    });

    for (final h in [
      ('nchian', 'Casa',            'assets/images/casa_nchian.jpg',  'nchian ra jngo — una casa'),
      ('nuxra',  'Cobija / Manta',  'assets/images/casa_nuxra.jpg',   'nuxra rua — cobija blanca'),
      ('xrui',   'Fuego / Fogón',   'assets/images/casa_xrui.jpg',    'xrui ra jngo — un fogón'),
      ('nthaa',  'Árbol / Madera',  'assets/images/casa_nthaa.jpg',   'nthaa ra tsje — muchos árboles'),
      ('xro',    'Piedra / Roca',   'assets/images/casa_xro.jpg',     'xro ra jngo — una piedra'),
      ('xroon',  'Papel',           'assets/images/casa_xroon.jpg',   'xroon ra jngo — un papel'),
      ('nunthe', 'Tierra / Suelo',  'assets/images/casa_nunthe.jpg',  'nunthe ra tsje — mucha tierra'),
      ('xra',    'Trabajo / Labor', 'assets/images/casa_xra.jpg',     'xra ra tsje — mucho trabajo'),
    ]) {
      await db.insert('words', {
        'lesson_id': l9, 'indigenous_word': h.$1, 'translation': h.$2,
        'audio_path': null, 'image_path': h.$3, 'example_phrase': h.$4,
      });
    }

    for (final q in [
      ('¿Cómo se dice "casa" en Ngigua?', 'xrui', 'nuxra', 'nchian', 'nthaa', 'c'),
      ('"nuxra" significa:', 'Casa', 'Fuego', 'Cobija / Manta', 'Árbol', 'c'),
      ('¿Cómo se dice "fuego" o "fogón" en Ngigua?', 'nchian', 'xro', 'xrui', 'nthaa', 'c'),
      ('"nthaa" en Ngigua significa:', 'Casa', 'Piedra', 'Cobija', 'Árbol / Madera', 'd'),
      ('¿Cómo se dice "piedra" en Ngigua?', 'xrui', 'xro', 'nthaa', 'nuxra', 'b'),
      ('"xroon" significa:', 'Fuego', 'Piedra', 'Árbol', 'Papel', 'd'),
      ('"xra" en Ngigua significa:', 'Casa', 'Trabajo / Labor', 'Fuego', 'Cobija', 'b'),
      ('¿Cómo se dice "tierra" o "suelo" en Ngigua?', 'nchian', 'nthaa', 'xro', 'nunthe', 'd'),
      ('¿Cuál de estos elementos NO pertenece al hogar?', 'xrui', 'nuxra', 'nchian', 'tsmjang', 'd'),
      ('"nchian ra jngo" significa:', 'Muchas casas', 'Una casa', 'La casa grande', 'Mi casa', 'b'),
      ('"nuxra rua" significaría:', 'Casa blanca', 'Cobija blanca', 'Árbol blanco', 'Piedra blanca', 'b'),
      ('"xrui ra jngo" es:', 'Una piedra', 'Un árbol', 'Un fogón / fuego', 'Una cobija', 'c'),
    ]) {
      await db.insert('quiz_questions', {
        'lesson_id': l9, 'question': q.$1, 'option_a': q.$2,
        'option_b': q.$3, 'option_c': q.$4, 'option_d': q.$5, 'correct_opt': q.$6,
      });
    }

    // ── LECCIÓN 10: Ropa y vestimenta ─────────────────────────────────────────
    final l10 = await db.insert('lessons', {
      'title': 'Ropa y vestimenta',
      'description':
          'Aprende cómo se llaman las prendas en Ngigua. '
          '"ruthe" es el rebozo tradicional.',
      'category': 'Ropa', 'difficulty': 3, 'created_at': now,
      'is_example': 1, 'order_index': 10, 'is_locked': 1, 'is_completed': 0,
    });

    for (final r in [
      ('ruthe',        'Rebozo / Chal',  'assets/images/ropa_ruthe.jpg',        'ruthe rua — rebozo blanco'),
      ('xranchritmja', 'Sombrero',       'assets/images/ropa_xranchritmja.jpg', 'xranchritmja jatse — sombrero rojo'),
      ('nthao',        'Carne / Gordo',  'assets/images/ropa_nthao.jpg',        'nthao ra tsje — mucha carne'),
      ('xra',          'Trabajo',        'assets/images/ropa_xra.jpg',          'xra ra tsje — mucho trabajo'),
      ('ruthe thie',   'Rebozo negro',   'assets/images/ropa_ruthethie.jpg',    'ruthe thie — rebozo negro de luto'),
      ('ruthe jatse',  'Rebozo rojo',    'assets/images/ropa_ruthejatse.jpg',   'ruthe jatse — rebozo colorado para fiesta'),
      ('nthao jatse',  'Carne roja',     'assets/images/ropa_nthaojatse.jpg',   'nthao jatse — carne colorada (guisado)'),
    ]) {
      await db.insert('words', {
        'lesson_id': l10, 'indigenous_word': r.$1, 'translation': r.$2,
        'audio_path': null, 'image_path': r.$3, 'example_phrase': r.$4,
      });
    }

    for (final q in [
      ('¿Cómo se dice "rebozo" en Ngigua?', 'xranchritmja', 'ruthe', 'xra', 'nthao', 'b'),
      ('"xranchritmja" es:', 'Rebozo', 'Cinturón', 'Sombrero', 'Huipil', 'c'),
      ('¿Cuál de estas prendas es tradicional de las mujeres de San Marcos?', 'xranchritmja', 'ruthe', 'camisa', 'zapato', 'b'),
      ('"ruthe rua" significa:', 'Sombrero blanco', 'Rebozo blanco', 'Camisa blanca', 'Zapato blanco', 'b'),
      ('¿Cómo se usa "xranchritmja"?', 'En los pies', 'En el cuello', 'En la cabeza', 'En la cintura', 'c'),
      ('"ruthe thie" es:', 'Rebozo blanco', 'Rebozo rojo', 'Rebozo negro', 'Rebozo amarillo', 'c'),
      ('"ruthe jatse" es:', 'Rebozo negro', 'Rebozo rojo', 'Rebozo blanco', 'Rebozo verde', 'b'),
      ('"xranchritmja jatse" sería:', 'Sombrero negro', 'Sombrero rojo', 'Sombrero blanco', 'Sombrero verde', 'b'),
      ('¿Qué prenda es "ruthe" en Ngigua?', 'Sombrero', 'Zapato', 'Cinturón', 'Rebozo', 'd'),
      ('"nthao" en Ngigua significa:', 'Ropa', 'Sombrero', 'Carne / Gordo', 'Rebozo', 'c'),
      ('Para combinar "ruthe" + color negro se dice:', 'ruthe rua', 'ruthe jatse', 'ruthe thie', 'ruthe sine', 'c'),
      ('"ruthe" + color + número: "ruthe rua ra yoo" significa:', 'Dos sombreros blancos', 'Dos rebozos blancos', 'Dos camisas blancas', 'Dos zapatos blancos', 'b'),
    ]) {
      await db.insert('quiz_questions', {
        'lesson_id': l10, 'question': q.$1, 'option_a': q.$2,
        'option_b': q.$3, 'option_c': q.$4, 'option_d': q.$5, 'correct_opt': q.$6,
      });
    }

    // ── LECCIÓN 11: El tiempo y el campo ──────────────────────────────────────
    final l11 = await db.insert('lessons', {
      'title': 'El tiempo y el campo',
      'description':
          'Aprende cómo se habla del tiempo y la naturaleza en Ngigua. '
          '"nchaon" es el sol o el día, "chrin" es la lluvia.',
      'category': 'Naturaleza', 'difficulty': 3, 'created_at': now,
      'is_example': 1, 'order_index': 11, 'is_locked': 1, 'is_completed': 0,
    });

    for (final n in [
      ('nchaon', 'Sol / Día',       'assets/images/tiempo_nchaon.jpg', 'nchaon ra jngo — un día de sol'),
      ('chrin',  'Lluvia',          'assets/images/tiempo_chrin.jpg',  'chrin ra tsje — mucha lluvia'),
      ('nunthe', 'Tierra / Suelo',  'assets/images/tiempo_nunthe.jpg', 'nunthe ra tsje — mucha tierra fértil'),
      ('nthaa',  'Monte / Árbol',   'assets/images/tiempo_nthaa.jpg',  'nthaa ra tsje — mucho monte'),
      ('xro',    'Piedra',          'assets/images/tiempo_xro.jpg',    'xro ra tsje — muchas piedras'),
      ('rajna',  'Pueblo / Lugar',  'assets/images/tiempo_rajna.jpg',  'rajna ra jngo — un pueblo'),
      ('nua',    'Milpa / Maíz',    'assets/images/tiempo_nua.jpg',    'nua ra tsje — mucha milpa'),
      ('xrui',   'Fuego / Calor',   'assets/images/tiempo_xrui.jpg',   'xrui ra jngo — un fuego / calor'),
    ]) {
      await db.insert('words', {
        'lesson_id': l11, 'indigenous_word': n.$1, 'translation': n.$2,
        'audio_path': null, 'image_path': n.$3, 'example_phrase': n.$4,
      });
    }

    for (final q in [
      ('¿Cómo se dice "sol" o "día" en Ngigua?', 'chrin', 'nchaon', 'nunthe', 'nthaa', 'b'),
      ('"chrin" en Ngigua significa:', 'Sol', 'Viento', 'Lluvia', 'Frío', 'c'),
      ('¿Cómo se dice "tierra" o "suelo" en Ngigua?', 'nchaon', 'chrin', 'nunthe', 'rajna', 'c'),
      ('"nthaa" puede referirse a:', 'El río', 'La lluvia', 'El árbol / el monte', 'El sol', 'c'),
      ('¿Cómo se dice "pueblo" o "lugar" en Ngigua?', 'nunthe', 'nchaon', 'nthaa', 'rajna', 'd'),
      ('"nua" en el campo se refiere a:', 'La lluvia', 'El árbol', 'El maíz / la milpa', 'La piedra', 'c'),
      ('"nchaon ra jngo" significa:', 'Mucho sol', 'Un día', 'Muchos días', 'La noche', 'b'),
      ('¿Cuál de estos describe tiempo lluvioso?', 'nchaon jian', 'nchaon thie', 'chrin', 'nchaon jngo', 'c'),
      ('"nunthe" es importante en la agricultura porque es:', 'El agua', 'El sol', 'La semilla', 'La tierra', 'd'),
      ('"chrin ra tsje" significaría:', 'Poco sol', 'Mucha lluvia', 'Muchos días', 'Mucho calor', 'b'),
      ('El ciclo del campo en Ngigua incluye nua + nunthe + nchaon. ¿Qué es esto?', 'Maíz + tierra + sol', 'Lluvia + piedra + fuego', 'Pueblo + árbol + agua', 'Animal + casa + ropa', 'a'),
      ('"xrui" en contexto del campo significa:', 'Lluvia', 'Frío', 'Fuego / Calor', 'Viento', 'c'),
    ]) {
      await db.insert('quiz_questions', {
        'lesson_id': l11, 'question': q.$1, 'option_a': q.$2,
        'option_b': q.$3, 'option_c': q.$4, 'option_d': q.$5, 'correct_opt': q.$6,
      });
    }

    // ── LECCIÓN 12: Frases del día a día ─────────────────────────────────────
    final l12 = await db.insert('lessons', {
      'title': 'Frases del día a día',
      'description':
          'Combina el vocabulario aprendido para formar frases útiles en Ngigua. '
          'Esta lección integra todo el nivel A1.',
      'category': 'Frases', 'difficulty': 4, 'created_at': now,
      'is_example': 1, 'order_index': 12, 'is_locked': 1, 'is_completed': 0,
    });

    for (final f in [
      ('deo',          'Hola / Saludo al encontrar',  'assets/images/frase_deo.jpg',        'Deo — saludo informal al cruzarse'),
      ('jian',         'Bien / Estoy bien',            'assets/images/frase_jian.jpg',        'Jian — respuesta positiva a "¿cómo estás?"'),
      ('thji',         'Vamos / Ve',                   'assets/images/frase_thji.jpg',        'thji nthia — vamos allá'),
      ('nthii',        'Aquí',                         'assets/images/frase_nthii.jpg',       'tsjee nthii — mira aquí'),
      ('nthia',        'Allá / Ahí',                   'assets/images/frase_nthia.jpg',       'thji nthia — ve allá'),
      ('jian nchaon',  'Buen día',                     'assets/images/frase_jiannchaon.jpg',  'jian nchaon — buenos días (lit. buen sol)'),
      ('nichma Ngigua','Habla Ngigua / Hablar Ngigua', 'assets/images/frase_nichma.jpg',      'nichma Ngigua — habla la lengua Ngigua'),
    ]) {
      await db.insert('words', {
        'lesson_id': l12, 'indigenous_word': f.$1, 'translation': f.$2,
        'audio_path': null, 'image_path': f.$3, 'example_phrase': f.$4,
      });
    }

    for (final q in [
      ('"jian" como respuesta a un saludo significa:', 'No muy bien', 'Bien / Bueno', 'Más o menos', 'Muy mal', 'b'),
      ('Para saludar al encontrarse en el camino dices:', 'jian', 'chee', 'deo', 'juajna', 'c'),
      ('"thji" se puede usar para decir:', 'Aquí estoy', 'Vamos', 'Ya llegué', 'Estoy bien', 'b'),
      ('"nthii" en Ngigua significa:', 'Allá', 'Aquí', 'Lejos', 'Cerca', 'b'),
      ('"nthia" significa:', 'Aquí', 'Arriba', 'Allá / Ahí', 'Abajo', 'c'),
      ('"jian nchaon" podría significar:', 'Buenas noches', 'Buen día', 'Hasta mañana', 'Buenas tardes', 'b'),
      ('Para decir "Habla Ngigua" usas:', 'tsjee Ngigua', 'thji Ngigua', 'nichma Ngigua', 'thii Ngigua', 'c'),
      ('¿Qué responderías a "¿Jian?" si estás bien?', 'Chee', 'Jian', 'Deo', 'Thji', 'b'),
      ('Para pedir a alguien que venga, usas:', 'thji', 'thii', 'tsjee', 'nichma', 'b'),
      ('"chee na" (yo estoy alegre) es respuesta positiva a:', '¿Cuánto cuesta?', '¿Cómo te llamas?', '¿Cómo estás?', '¿Adónde vas?', 'c'),
      ('¿Cuál de estas es una frase de partida / movimiento?', 'deo', 'nthii', 'thji nthia', 'jian', 'c'),
      ('"jian nchaon" combina "jian" (bien) + "nchaon" (sol/día). ¿Qué es?', 'Una despedida', 'Un saludo matutino', 'Una pregunta', 'Un color', 'b'),
    ]) {
      await db.insert('quiz_questions', {
        'lesson_id': l12, 'question': q.$1, 'option_a': q.$2,
        'option_b': q.$3, 'option_c': q.$4, 'option_d': q.$5, 'correct_opt': q.$6,
      });
    }
  }
}
```

- [ ] **Step 2: Commit**
```bash
git add lib/core/database/database_seeder.dart
git commit -m "feat: full A1 seeder — 12 lessons, 10+ quiz questions each, example phrases per word"
```

---

## Task 13: Download Images for Lessons 6–12

**Files:**
- Run Python script → `assets/images/`

- [ ] **Step 1: Run the download script**

Save this as `scripts/download_images.py` and run it from the project root:

```python
#!/usr/bin/env python3
"""
Downloads watercolor images from the MET Open Access API for TayuNikan lessons 6-12.
Usage: python scripts/download_images.py
"""
import urllib.request, urllib.parse, json, os, time

OUT_DIR = "assets/images"
os.makedirs(OUT_DIR, exist_ok=True)

IMAGES = [
    # Lesson 6: Cuerpo
    ("cuerpo_jaa",       "head portrait watercolor"),
    ("cuerpo_jmakon",    "eye watercolor painting"),
    ("cuerpo_chintmjon", "nose face watercolor"),
    ("cuerpo_rua",       "mouth lips watercolor"),
    ("cuerpo_raa",       "hand arm watercolor"),
    ("cuerpo_ruthea",    "foot leg watercolor"),
    ("cuerpo_neje",      "tongue mouth watercolor"),
    ("cuerpo_thusin",    "neck figure watercolor"),
    # Lesson 7: Alimentos
    ("alimento_nio",       "tortilla bread watercolor"),
    ("alimento_nua",       "corn maize watercolor"),
    ("alimento_niunthaon", "tamale food watercolor"),
    ("alimento_thukma",    "potato vegetable watercolor"),
    ("alimento_thuchmoin", "fruit watercolor painting"),
    ("alimento_ndaxra",    "stew food bowl watercolor"),
    ("alimento_tumi",      "coins money watercolor"),
    # Lesson 8: Verbos
    ("verbo_nichma",  "people talking conversation watercolor"),
    ("verbo_thji",    "walking figure watercolor"),
    ("verbo_thii",    "arriving figure watercolor"),
    ("verbo_tsjee",   "looking watching watercolor"),
    ("verbo_thjen",   "washing hands watercolor"),
    ("verbo_tsmjan",  "laughing figure watercolor"),
    ("verbo_tsmjang", "crying figure watercolor"),
    ("verbo_ruchrin", "jumping figure watercolor"),
    # Lesson 9: Casa
    ("casa_nchian",  "house building watercolor"),
    ("casa_nuxra",   "blanket textile watercolor"),
    ("casa_xrui",    "fire flame watercolor"),
    ("casa_nthaa",   "tree wood watercolor"),
    ("casa_xro",     "stone rock watercolor"),
    ("casa_xroon",   "paper book watercolor"),
    ("casa_nunthe",  "earth soil watercolor"),
    ("casa_xra",     "labor work watercolor"),
    # Lesson 10: Ropa
    ("ropa_ruthe",        "shawl textile woven watercolor"),
    ("ropa_xranchritmja", "hat sombrero watercolor"),
    ("ropa_nthao",        "meat food watercolor"),
    ("ropa_xra",          "work labor watercolor"),
    ("ropa_ruthethie",    "black shawl textile watercolor"),
    ("ropa_ruthejatse",   "red shawl textile watercolor"),
    ("ropa_nthaojatse",   "red meat food watercolor"),
    # Lesson 11: Tiempo/Campo
    ("tiempo_nchaon", "sun day watercolor"),
    ("tiempo_chrin",  "rain watercolor painting"),
    ("tiempo_nunthe", "earth field watercolor"),
    ("tiempo_nthaa",  "forest trees watercolor"),
    ("tiempo_xro",    "rocks stones watercolor"),
    ("tiempo_rajna",  "village town watercolor"),
    ("tiempo_nua",    "cornfield milpa watercolor"),
    ("tiempo_xrui",   "fire heat watercolor"),
    # Lesson 12: Frases
    ("frase_deo",        "greeting people watercolor"),
    ("frase_jian",       "happy person smile watercolor"),
    ("frase_thji",       "walking path watercolor"),
    ("frase_nthii",      "here place watercolor"),
    ("frase_nthia",      "there distance watercolor"),
    ("frase_jiannchaon", "sunrise morning watercolor"),
    ("frase_nichma",     "speaking language watercolor"),
]

SKIP_IDS = set()

def search_met(query, skip_ids):
    url = "https://collectionapi.metmuseum.org/public/collection/v1/search"
    params = urllib.parse.urlencode({"q": query, "medium": "Watercolors", "hasImages": "true"})
    try:
        with urllib.request.urlopen(f"{url}?{params}", timeout=10) as r:
            data = json.loads(r.read())
        ids = [i for i in (data.get("objectIDs") or []) if i not in skip_ids]
        return ids[:20]
    except Exception as e:
        print(f"  Search error: {e}")
        return []

def get_image_url(obj_id):
    url = f"https://collectionapi.metmuseum.org/public/collection/v1/objects/{obj_id}"
    try:
        with urllib.request.urlopen(url, timeout=10) as r:
            data = json.loads(r.read())
        return data.get("primaryImageSmall") or data.get("primaryImage")
    except Exception:
        return None

def download(name, query):
    out_path = os.path.join(OUT_DIR, f"{name}.jpg")
    if os.path.exists(out_path):
        print(f"  {name}.jpg already exists, skipping")
        return
    ids = search_met(query, SKIP_IDS)
    for obj_id in ids:
        img_url = get_image_url(obj_id)
        if not img_url:
            continue
        try:
            urllib.request.urlretrieve(img_url, out_path)
            SKIP_IDS.add(obj_id)
            print(f"  ✓ {name}.jpg (MET #{obj_id})")
            return
        except Exception as e:
            print(f"  Download error for {obj_id}: {e}")
    print(f"  ✗ No image found for {name} (query: {query})")

if __name__ == "__main__":
    for name, query in IMAGES:
        print(f"Downloading {name}...")
        download(name, query)
        time.sleep(0.3)
    print("Done.")
```

Run:
```bash
python scripts/download_images.py
```

- [ ] **Step 2: Verify images downloaded**
```bash
ls assets/images/ | wc -l
# Should be ~80 (25 existing + ~55 new)
```

- [ ] **Step 3: Commit images**
```bash
git add assets/images/
git commit -m "assets: add watercolor images for lessons 6-12"
```

---

## Task 14: Reset DB and Verify Full Flow

- [ ] **Step 1: Uninstall the app from the device/emulator to force fresh DB**

On Android emulator:
```bash
flutter run  # or adb uninstall com.tayunikan.tayunikan first
```

- [ ] **Step 2: Smoke test**
1. App opens → Welcome screen ✓
2. Go to Lecciones → Lesson 1 unlocked, Lessons 2-12 locked ✓
3. "Diagnóstico" button visible in AppBar ✓
4. Tap a locked lesson → nothing happens (no navigation) ✓
5. Complete Lesson 1 quiz with ≥70% → Lesson 2 unlocks ✓
6. Tap Diagnóstico → 24 questions → result screen with unlocked lessons ✓
7. Settings → Reiniciar diagnóstico → button reappears in Lecciones ✓

- [ ] **Step 3: Push to GitHub**
```bash
git push origin main
```

---

## Self-Review Checklist

- [x] **Spec coverage:** DB migration ✓ | Lesson model ✓ | Sequential unlock ✓ | Diagnostic exam ✓ | 12 lessons ✓ | 10+ questions each ✓ | Example phrases all words ✓ | Images in quiz ✓ | Reset diagnostic in settings ✓
- [x] **No placeholders:** All code is complete
- [x] **Type consistency:** `completeLesson(int lessonId, int orderIndex)` in provider matches call in QuizScreen; `unlockLessons(List<int>)` matches DiagnosticExamScreen call; `Map<int, bool> results` and `Map<int, String> lessonTitles` match between DiagnosticExamScreen and DiagnosticResultScreen route args
- [x] **Vocabulary note:** Lessons 6-12 use words from *Gramática Ngigua* (ILV) appendix. All marked `is_example: 1` for validation reminder.
