import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/lesson.dart';
import '../../providers/lesson_provider.dart';

/// Pantalla para crear o editar una lección (solo admin).
class CreateLessonScreen extends StatefulWidget {
  final Lesson? lessonToEdit; // null = crear nueva

  const CreateLessonScreen({super.key, this.lessonToEdit});

  @override
  State<CreateLessonScreen> createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends State<CreateLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  String _category = 'Vocabulario';
  int _difficulty = 1;
  bool _isSaving = false;

  static const List<String> _categories = [
    'Vocabulario',
    'Saludos',
    'Números',
    'Colores',
    'Familia',
    'Animales',
    'Naturaleza',
    'Frases',
    'Cultura',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    final lesson = widget.lessonToEdit;
    _titleCtrl = TextEditingController(text: lesson?.title ?? '');
    _descriptionCtrl =
        TextEditingController(text: lesson?.description ?? '');
    if (lesson != null) {
      _category = lesson.category;
      _difficulty = lesson.difficulty;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<LessonProvider>();
    final isEdit = widget.lessonToEdit != null;

    final lesson = Lesson(
      id: widget.lessonToEdit?.id,
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      category: _category,
      difficulty: _difficulty,
      createdAt: DateTime.now().toIso8601String(),
      isExample: false,
    );

    try {
      if (isEdit) {
        await provider.updateLesson(lesson);
      } else {
        await provider.addLesson(lesson);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.lessonToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar lección' : 'Nueva lección'),
        backgroundColor: AppColors.secondary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Título
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Título de la lección *',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'El título es requerido' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Categoría
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Categoría *',
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 20),

            // Nivel de dificultad
            const Text(
              'Nivel de dificultad',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            _DifficultySelector(
              value: _difficulty,
              onChanged: (v) => setState(() => _difficulty = v),
            ),
            const SizedBox(height: 32),

            // Botón guardar
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_rounded),
              label: Text(isEdit ? 'Guardar cambios' : 'Crear lección'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _DifficultySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [
      (1, 'Fácil', AppColors.difficultyEasy),
      (2, 'Intermedio', AppColors.difficultyMedium),
      (3, 'Difícil', AppColors.difficultyHard),
    ];

    return Row(
      children: options
          .map((opt) => Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(opt.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: value == opt.$1
                          ? opt.$3.withOpacity(0.15)
                          : Colors.white,
                      border: Border.all(
                        color: value == opt.$1 ? opt.$3 : AppColors.lightGray,
                        width: value == opt.$1 ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.circle,
                            size: 10,
                            color: value == opt.$1
                                ? opt.$3
                                : AppColors.lightGray),
                        const SizedBox(height: 4),
                        Text(
                          opt.$2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: value == opt.$1
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: value == opt.$1
                                ? opt.$3
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
