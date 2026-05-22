import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';
import 'lessons/lesson_list_screen.dart';
import 'activities/activities_screen.dart';
import 'progress/progress_screen.dart';
import 'cultural/cultural_screen.dart';

/// Pantalla principal con navegación inferior (Bottom Navigation Bar).
/// Los 4 módulos: Lecciones, Actividades, Mi Avance, Cultural.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    LessonListScreen(),
    ActivitiesScreen(),
    ProgressScreen(),
    CulturalScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.menu_book_outlined),
      activeIcon: Icon(Icons.menu_book),
      label: 'Lecciones',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.extension_outlined),
      activeIcon: Icon(Icons.extension),
      label: 'Actividades',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bar_chart_outlined),
      activeIcon: Icon(Icons.bar_chart),
      label: 'Mi Avance',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.language_outlined),
      activeIcon: Icon(Icons.language),
      label: 'Cultural',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _navItems,
      ),
      // Botón flotante de administración (solo en modo admin)
      floatingActionButton: auth.isAdminMode
          ? FloatingActionButton(
              heroTag: 'admin_fab',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.adminPanel),
              backgroundColor: AppColors.secondary,
              tooltip: 'Panel de administración',
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.white),
            )
          : null,
    );
  }
}
