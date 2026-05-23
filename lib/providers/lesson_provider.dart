import 'package:flutter/foundation.dart';
import '../core/models/lesson.dart';
import '../core/models/word.dart';
import '../core/models/quiz_question.dart';
import '../core/repositories/lesson_repository.dart';
import '../core/repositories/word_repository.dart';
import '../core/repositories/quiz_repository.dart';

/// Maneja el estado de lecciones, palabras y preguntas de quiz.
class LessonProvider extends ChangeNotifier {
  final LessonRepository _lessonRepo = LessonRepository();
  final WordRepository _wordRepo = WordRepository();
  final QuizRepository _quizRepo = QuizRepository();

  List<Lesson> _lessons = [];
  List<Word> _currentWords = [];
  List<QuizQuestion> _currentQuestions = [];
  bool _isLoading = false;
  String? _error;

  List<Lesson> get lessons => _lessons;
  List<Word> get currentWords => _currentWords;
  List<QuizQuestion> get currentQuestions => _currentQuestions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ─── Lecciones ─────────────────────────────────────────────────────────────

  Future<void> loadLessons() async {
    _setLoading(true);
    try {
      _lessons = await _lessonRepo.getLessonsOrdered();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Marca la lección como completada y desbloquea la siguiente.
  /// Se llama desde QuizScreen cuando el estudiante pasa con ≥70%.
  Future<void> completeLesson(int lessonId, int orderIndex) async {
    await _lessonRepo.markCompleted(lessonId);
    await _lessonRepo.unlockNext(orderIndex + 1);
    await loadLessons();
  }

  Future<int> addLesson(Lesson lesson) async {
    final id = await _lessonRepo.insertLesson(lesson);
    await loadLessons();
    return id;
  }

  Future<void> updateLesson(Lesson lesson) async {
    await _lessonRepo.updateLesson(lesson);
    await loadLessons();
  }

  Future<void> deleteLesson(int id) async {
    await _lessonRepo.deleteLesson(id);
    await loadLessons();
  }

  // ─── Palabras ──────────────────────────────────────────────────────────────

  Future<void> loadWordsForLesson(int lessonId) async {
    _setLoading(true);
    try {
      _currentWords = await _wordRepo.getWordsByLesson(lessonId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addWord(Word word) async {
    await _wordRepo.insertWord(word);
    await loadWordsForLesson(word.lessonId);
  }

  Future<void> updateWord(Word word) async {
    await _wordRepo.updateWord(word);
    await loadWordsForLesson(word.lessonId);
  }

  Future<void> deleteWord(Word word) async {
    await _wordRepo.deleteWord(word.id!);
    await loadWordsForLesson(word.lessonId);
  }

  // ─── Quiz ──────────────────────────────────────────────────────────────────

  Future<void> loadQuestionsForLesson(int lessonId) async {
    _setLoading(true);
    try {
      _currentQuestions = await _quizRepo.getQuestionsByLesson(lessonId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addQuestion(QuizQuestion question) async {
    await _quizRepo.insertQuestion(question);
    await loadQuestionsForLesson(question.lessonId);
  }

  Future<void> deleteQuestion(QuizQuestion question) async {
    await _quizRepo.deleteQuestion(question.id!);
    await loadQuestionsForLesson(question.lessonId);
  }

  // ─── Utilidades ────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<int> getWordCount(int lessonId) =>
      _wordRepo.getWordCountForLesson(lessonId);
}
