import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/lesson_provider.dart';
import 'providers/progress_provider.dart';
import 'core/services/settings_service.dart';
import 'core/database/database_seeder.dart';
import 'core/database/database_helper.dart';

/// Punto de entrada principal de TayuNikan.
///
/// 1. Inicializa Flutter (obligatorio para operaciones async antes de runApp).
/// 2. Carga datos de ejemplo en el primer lanzamiento.
/// 3. Configura los providers de estado.
/// 4. Ejecuta la app.
void main() async {
  // Necesario para usar APIs de Flutter antes de runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquear orientación horizontal para mejor UX en app educativa
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Seed de datos: en primer lanzamiento O si la migración v3 borró el contenido
  final settings = SettingsService();
  final db = DatabaseHelper.instance;
  final lessons = await db.queryAll('lessons');
  if (await settings.isFirstLaunch || lessons.isEmpty) {
    await DatabaseSeeder.seed();
    await settings.setFirstLaunchComplete();
  }

  runApp(
    MultiProvider(
      providers: [
        // Autenticación (modo admin) y estado premium
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
        ),
        // Estado de lecciones, palabras y quiz
        ChangeNotifierProvider(
          create: (_) => LessonProvider()..loadLessons(),
        ),
        // Progreso del estudiante
        ChangeNotifierProvider(
          create: (_) => ProgressProvider()..loadProgress(),
        ),
      ],
      child: const TayuNikan(),
    ),
  );
}
