import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/models/lesson.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/lesson_card.dart';
import '../../widgets/ad_banner_widget.dart';

/// Lista de todas las lecciones disponibles.
class LessonListScreen extends StatefulWidget {
  const LessonListScreen({super.key});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  bool _diagnosticCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonProvider>().loadLessons();
      context.read<ProgressProvider>().loadProgress();
      _checkDiagnostic();
    });
  }

  Future<void> _checkDiagnostic() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _diagnosticCompleted = prefs.getBool('diagnosticCompleted') ?? false;
      });
    }
  }

  Future<void> _openDiagnostic() async {
    await Navigator.pushNamed(context, AppRoutes.diagnosticExam);
    // Recargar lecciones y estado del diagnóstico al regresar
    if (mounted) {
      context.read<LessonProvider>().loadLessons();
      await _checkDiagnostic();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecciones'),
        actions: [
          // Botón de diagnóstico (visible si no se ha completado)
          if (!_diagnosticCompleted)
            IconButton(
              icon: const Icon(Icons.quiz_outlined),
              tooltip: 'Diagnóstico de nivel',
              onPressed: _openDiagnostic,
            ),
          // Acceso al modo admin desde el ícono de configuración
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
      body: Column(
        children: [
          Expanded(
            child: _buildBody(lessonProvider, progressProvider, auth),
          ),
          // Banner de publicidad (solo usuarios no-premium)
          const AdBannerWidget(),
        ],
      ),
      // Botón para crear lección (solo admin)
      floatingActionButton: auth.isAdminMode
          ? FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.createLesson)
                      .then((_) => lessonProvider.loadLessons()),
              icon: const Icon(Icons.add),
              label: const Text('Nueva lección'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget _buildBody(
    LessonProvider lessonProvider,
    ProgressProvider progressProvider,
    AuthProvider auth,
  ) {
    if (lessonProvider.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (lessonProvider.lessons.isEmpty) {
      return _EmptyState(isAdmin: auth.isAdminMode);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await lessonProvider.loadLessons();
        await progressProvider.loadProgress();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: lessonProvider.lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessonProvider.lessons[index];
          return _LessonCardWrapper(
            lesson: lesson,
            lessonProvider: lessonProvider,
            progressProvider: progressProvider,
            isAdmin: auth.isAdminMode,
          );
        },
      ),
    );
  }
}

class _LessonCardWrapper extends StatefulWidget {
  final Lesson lesson;
  final LessonProvider lessonProvider;
  final ProgressProvider progressProvider;
  final bool isAdmin;

  const _LessonCardWrapper({
    required this.lesson,
    required this.lessonProvider,
    required this.progressProvider,
    required this.isAdmin,
  });

  @override
  State<_LessonCardWrapper> createState() => _LessonCardWrapperState();
}

class _LessonCardWrapperState extends State<_LessonCardWrapper> {
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _loadWordCount();
  }

  Future<void> _loadWordCount() async {
    final count =
        await widget.lessonProvider.getWordCount(widget.lesson.id!);
    if (mounted) setState(() => _wordCount = count);
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        widget.progressProvider.getProgressForLesson(widget.lesson.id!);

    return LessonCard(
      lesson: widget.lesson,
      progress: progress,
      wordCount: _wordCount,
      isAdminMode: widget.isAdmin,
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.lessonDetail,
        arguments: widget.lesson,
      ).then((_) {
        widget.lessonProvider.loadLessons();
        widget.progressProvider.loadProgress();
      }),
      onEdit: widget.isAdmin
          ? () => Navigator.pushNamed(
                context,
                AppRoutes.editLesson,
                arguments: widget.lesson,
              ).then((_) => widget.lessonProvider.loadLessons())
          : null,
      onDelete: widget.isAdmin
          ? () => _confirmDelete(context)
          : null,
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar lección'),
        content: Text(
            '¿Eliminar "${widget.lesson.title}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.lessonProvider.deleteLesson(widget.lesson.id!);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isAdmin;
  const _EmptyState({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined,
                size: 80, color: AppColors.lightGray),
            const SizedBox(height: 16),
            Text(
              isAdmin
                  ? 'No hay lecciones aún.\n¡Crea la primera!'
                  : 'No hay lecciones disponibles todavía.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
