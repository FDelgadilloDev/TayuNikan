import 'package:flutter/foundation.dart';
import '../core/models/user_progress.dart';
import '../core/repositories/progress_repository.dart';
import '../core/repositories/lesson_repository.dart';
import '../core/repositories/pronunciation_repository.dart';
import '../core/services/settings_service.dart';

/// Maneja el estado de avance del estudiante.
class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _progressRepo = ProgressRepository();
  final LessonRepository _lessonRepo = LessonRepository();
  final PronunciationRepository _pronRepo = PronunciationRepository();
  final SettingsService _settings = SettingsService();

  Map<int, UserProgress> _progressMap = {};
  int _totalLessons = 0;
  int _completedLessons = 0;
  int _totalWordsPracticed = 0;
  int _totalPronunciationAttempts = 0;
  int _practiceStreak = 0;

  Map<int, UserProgress> get progressMap => _progressMap;
  int get totalLessons => _totalLessons;
  int get completedLessons => _completedLessons;
  int get totalWordsPracticed => _totalWordsPracticed;
  int get totalPronunciationAttempts => _totalPronunciationAttempts;
  int get practiceStreak => _practiceStreak;

  /// Porcentaje de lecciones completadas (0.0 a 1.0).
  double get completionPercentage =>
      _totalLessons == 0 ? 0.0 : _completedLessons / _totalLessons;

  Future<void> loadProgress() async {
    final allProgress = await _progressRepo.getAllProgress();
    _progressMap = {for (final p in allProgress) p.lessonId: p};
    _totalLessons = await _lessonRepo.getTotalCount();
    _completedLessons = await _progressRepo.getCompletedCount();
    _totalWordsPracticed = await _progressRepo.getTotalWordsPracticed();
    _totalPronunciationAttempts = await _pronRepo.getTotalAttempts();
    _practiceStreak = await _settings.practiceStreak;
    notifyListeners();
  }

  UserProgress? getProgressForLesson(int lessonId) => _progressMap[lessonId];

  /// Marca una lección como completada con el puntaje del quiz.
  Future<void> markLessonCompleted(int lessonId, {int quizScore = 0}) async {
    final existing = await _progressRepo.getProgressForLesson(lessonId);
    final progress = (existing ?? UserProgress(lessonId: lessonId)).copyWith(
      completed: true,
      quizScore: quizScore,
      lastAccessed: DateTime.now().toIso8601String(),
    );
    await _progressRepo.upsertProgress(progress);
    await _settings.recordPracticeToday();
    await loadProgress();
  }

  /// Incrementa el contador de palabras practicadas para una lección.
  Future<void> incrementWordsPracticed(int lessonId,
      {int count = 1}) async {
    final existing = await _progressRepo.getProgressForLesson(lessonId);
    final current = existing ?? UserProgress(lessonId: lessonId);
    final updated = current.copyWith(
      wordsPracticed: current.wordsPracticed + count,
      lastAccessed: DateTime.now().toIso8601String(),
    );
    await _progressRepo.upsertProgress(updated);
    await _settings.recordPracticeToday();
    await loadProgress();
  }

  /// Devuelve el nivel de insignia según las lecciones completadas.
  ///
  /// 0 = sin insignia, 1 = bronce, 2 = plata, 3 = oro
  int get badgeLevel {
    if (_completedLessons == 0) return 0;
    if (_completedLessons < 3) return 1;
    if (_completedLessons < 6) return 2;
    return 3;
  }

  String get badgeLabel {
    switch (badgeLevel) {
      case 1:
        return 'Bronce';
      case 2:
        return 'Plata';
      case 3:
        return 'Oro';
      default:
        return 'Sin insignia';
    }
  }
}
