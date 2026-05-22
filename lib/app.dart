import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'core/models/lesson.dart';
import 'core/models/word.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lessons/lesson_detail_screen.dart';
import 'screens/lessons/word_detail_screen.dart';
import 'screens/quiz/quiz_screen.dart';
import 'screens/quiz/quiz_result_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'screens/admin/create_lesson_screen.dart';
import 'screens/admin/add_word_screen.dart';
import 'screens/settings/settings_screen.dart';

/// Punto de entrada del MaterialApp de TayuNikan.
/// Define el tema, rutas nombradas y la ruta inicial.
class TayuNikan extends StatelessWidget {
  const TayuNikan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TayuNikan',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.welcome,

      // Rutas estáticas (sin argumentos)
      routes: {
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.adminLogin: (_) => const AdminLoginScreen(),
        AppRoutes.adminPanel: (_) => const AdminPanelScreen(),
        AppRoutes.createLesson: (_) => const CreateLessonScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },

      // Rutas dinámicas (con argumentos tipados)
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.lessonDetail:
            return MaterialPageRoute(
              builder: (_) =>
                  LessonDetailScreen(lesson: settings.arguments as Lesson),
            );

          case AppRoutes.editLesson:
            return MaterialPageRoute(
              builder: (_) => CreateLessonScreen(
                  lessonToEdit: settings.arguments as Lesson),
            );

          case AppRoutes.wordDetail:
            return MaterialPageRoute(
              builder: (_) =>
                  WordDetailScreen(word: settings.arguments as Word),
            );

          case AppRoutes.quiz:
            return MaterialPageRoute(
              builder: (_) =>
                  QuizScreen(lessonId: settings.arguments as int),
            );

          case AppRoutes.quizResult:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => QuizResultScreen(
                score: args['score'] as int,
                total: args['total'] as int,
                lessonId: args['lessonId'] as int,
              ),
            );

          case AppRoutes.addWord:
            return MaterialPageRoute(
              builder: (_) =>
                  AddWordScreen(lessonId: settings.arguments as int),
            );

          case AppRoutes.editWord:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AddWordScreen(
                lessonId: args['lessonId'] as int,
                wordToEdit: args['word'] as Word,
              ),
            );

          default:
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
        }
      },
    );
  }
}
