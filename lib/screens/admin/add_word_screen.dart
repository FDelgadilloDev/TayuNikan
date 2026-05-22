import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/word.dart';
import '../../providers/lesson_provider.dart';

/// Pantalla para agregar o editar una palabra en una lección (solo admin).
class AddWordScreen extends StatefulWidget {
  final int lessonId;
  final Word? wordToEdit;

  const AddWordScreen({super.key, required this.lessonId, this.wordToEdit});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _wordCtrl;
  late final TextEditingController _translationCtrl;
  late final TextEditingController _phraseCtrl;
  String? _audioPath;
  String? _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final w = widget.wordToEdit;
    _wordCtrl = TextEditingController(text: w?.indigenousWord ?? '');
    _translationCtrl = TextEditingController(text: w?.translation ?? '');
    _phraseCtrl = TextEditingController(text: w?.examplePhrase ?? '');
    _audioPath = w?.audioPath;
    _imagePath = w?.imagePath;
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _translationCtrl.dispose();
    _phraseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _audioPath = result.files.single.path);
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _imagePath = result.files.single.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<LessonProvider>();
    final isEdit = widget.wordToEdit != null;

    final word = Word(
      id: widget.wordToEdit?.id,
      lessonId: widget.lessonId,
      indigenousWord: _wordCtrl.text.trim(),
      translation: _translationCtrl.text.trim(),
      audioPath: _audioPath,
      imagePath: _imagePath,
      examplePhrase: _phraseCtrl.text.trim().isEmpty
          ? null
          : _phraseCtrl.text.trim(),
    );

    try {
      if (isEdit) {
        await provider.updateWord(word);
      } else {
        await provider.addWord(word);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.wordToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar palabra' : 'Agregar palabra'),
        backgroundColor: AppColors.secondary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Palabra en la lengua indígena
            TextFormField(
              controller: _wordCtrl,
              decoration: const InputDecoration(
                labelText: 'Palabra en la lengua indígena *',
                prefixIcon: Icon(Icons.translate),
                hintText: '[PALABRA_DE_EJEMPLO]',
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'La palabra es requerida'
                  : null,
            ),
            const SizedBox(height: 16),

            // Traducción al español
            TextFormField(
              controller: _translationCtrl,
              decoration: const InputDecoration(
                labelText: 'Traducción al español *',
                prefixIcon: Icon(Icons.spellcheck),
                hintText: '[TRADUCCION]',
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'La traducción es requerida'
                  : null,
            ),
            const SizedBox(height: 16),

            // Frase de ejemplo
            TextFormField(
              controller: _phraseCtrl,
              decoration: const InputDecoration(
                labelText: 'Frase de ejemplo (opcional)',
                prefixIcon: Icon(Icons.format_quote),
                alignLabelWithHint: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Seleccionar audio
            const Text(
              'Audio de pronunciación',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            _FilePicker(
              label: _audioPath != null
                  ? _audioPath!.split('/').last
                  : 'Seleccionar archivo de audio',
              icon: Icons.audio_file_rounded,
              color: AppColors.secondary,
              onTap: _pickAudio,
              selected: _audioPath != null,
            ),
            const SizedBox(height: 16),

            // Seleccionar imagen
            const Text(
              'Imagen (opcional)',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            _FilePicker(
              label: _imagePath != null
                  ? _imagePath!.split('/').last
                  : 'Seleccionar imagen',
              icon: Icons.image_rounded,
              color: AppColors.accent,
              onTap: _pickImage,
              selected: _imagePath != null,
            ),
            const SizedBox(height: 12),
            Text(
              '⚠ El contenido debe ser validado por hablantes nativos de la comunidad.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.accent,
                fontStyle: FontStyle.italic,
              ),
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
              label: Text(isEdit ? 'Guardar cambios' : 'Agregar palabra'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilePicker extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool selected;

  const _FilePicker({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.08) : Colors.white,
          border: Border.all(
            color: selected ? color : AppColors.lightGray,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? color : AppColors.textSecondary,
                  fontSize: 14,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
