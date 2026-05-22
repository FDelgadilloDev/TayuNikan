import '../database/database_helper.dart';

/// Carga datos iniciales en la base de datos en el primer lanzamiento.
///
/// Vocabulario Ngigua de San Marcos Tlacoyalco, Puebla.
/// Fuente: "Vocabulario Diccionario Ngiigua" — Sharon Stark Campbell,
/// Jacob Luna Hernández, Verónica Luna Villanueva. UNTI A.C., 2016.
///
/// ⚠ El contenido debe ser validado por hablantes nativos de la comunidad.
class DatabaseSeeder {
  static Future<void> seed() async {
    final db = DatabaseHelper.instance;
    final now = DateTime.now().toIso8601String();

    // ── LECCIÓN 1: Saludos básicos ────────────────────────────────────────────
    final lesson1Id = await db.insert('lessons', {
      'title': 'Saludos básicos',
      'description':
          'Aprende a saludar y expresar bienestar en Ngigua, '
              'la lengua de San Marcos Tlacoyalco, Puebla. '
              'Los saludos son la puerta de entrada a cualquier conversación.',
      'category': 'Saludos',
      'difficulty': 1,
      'created_at': now,
      'is_example': 1,
    });

    final saludos = [
      // (palabra ngigua, traducción, frase ejemplo)
      ('deo', 'Saludo al encontrar a alguien', 'Deo — se dice al cruzarse con alguien en el camino'),
      ('jian', 'Bien / Bueno', 'Jian — estoy bien'),
      ('jaro', 'Bonito / De buen carácter', null),
      ('chee', 'Estar alegre / Estar contento', 'Chéna — yo estoy alegre'),
      ('juajna', 'Saludo / Mensaje', null),
    ];

    for (final s in saludos) {
      await db.insert('words', {
        'lesson_id': lesson1Id,
        'indigenous_word': s.$1,
        'translation': s.$2,
        'audio_path': null,
        'image_path': null,
        'example_phrase': s.$3,
      });
    }

    await db.insert('quiz_questions', {
      'lesson_id': lesson1Id,
      'question': '¿Cómo se saluda al encontrar a alguien en Ngigua?',
      'option_a': 'deo',
      'option_b': 'jian',
      'option_c': 'chee',
      'option_d': 'juajna',
      'correct_opt': 'a',
    });
    await db.insert('quiz_questions', {
      'lesson_id': lesson1Id,
      'question': '¿Qué significa "jian" en Ngigua?',
      'option_a': 'Triste',
      'option_b': 'Bien / Bueno',
      'option_c': 'Saludo',
      'option_d': 'Familia',
      'correct_opt': 'b',
    });
    await db.insert('quiz_questions', {
      'lesson_id': lesson1Id,
      'question': '"chee" en Ngigua significa:',
      'option_a': 'Estar cansado',
      'option_b': 'Estar enojado',
      'option_c': 'Estar alegre / contento',
      'option_d': 'Estar enfermo',
      'correct_opt': 'c',
    });

    // ── LECCIÓN 2: Números del 1 al 5 ────────────────────────────────────────
    final lesson2Id = await db.insert('lessons', {
      'title': 'Números del 1 al 5',
      'description':
          'Aprende a contar del 1 al 5 en Ngigua. '
              'El Ngigua usa un sistema vigesimal (base 20): '
              '"kan" = veinte, "yoo kan" = cuarenta.',
      'category': 'Números',
      'difficulty': 1,
      'created_at': now,
      'is_example': 1,
    });

    final numeros = [
      ('jngo', 'Uno (1)'),
      ('yoo', 'Dos (2)'),
      ('nii', 'Tres (3)'),
      ('noo', 'Cuatro (4)'),
      ('nao', 'Cinco (5)'),
    ];

    for (final n in numeros) {
      await db.insert('words', {
        'lesson_id': lesson2Id,
        'indigenous_word': n.$1,
        'translation': n.$2,
        'audio_path': null,
        'image_path': null,
        'example_phrase': null,
      });
    }

    await db.insert('quiz_questions', {
      'lesson_id': lesson2Id,
      'question': '¿Cómo se dice "Uno" en Ngigua?',
      'option_a': 'yoo',
      'option_b': 'nao',
      'option_c': 'jngo',
      'option_d': 'nii',
      'correct_opt': 'c',
    });
    await db.insert('quiz_questions', {
      'lesson_id': lesson2Id,
      'question': '"noo" es el número:',
      'option_a': 'Tres',
      'option_b': 'Cuatro',
      'option_c': 'Cinco',
      'option_d': 'Dos',
      'correct_opt': 'b',
    });

    // ── LECCIÓN 3: Colores ────────────────────────────────────────────────────
    final lesson3Id = await db.insert('lessons', {
      'title': 'Colores',
      'description':
          'Aprende los colores básicos en Ngigua. '
              'En Ngigua, la palabra "nao" también significa "color" en general.',
      'category': 'Vocabulario',
      'difficulty': 2,
      'created_at': now,
      'is_example': 1,
    });

    final colores = [
      ('jatse', 'Rojo / Colorado', 'ndaxra jatse — mole (lit. salsa roja)'),
      ('yua', 'Verde / Azul', 'jnayua — chile verde'),
      ('rua', 'Blanco / Limpio', null),
      ('sine', 'Amarillo', null),
      ('thie', 'Negro / Noche', null),
    ];

    for (final c in colores) {
      await db.insert('words', {
        'lesson_id': lesson3Id,
        'indigenous_word': c.$1,
        'translation': c.$2,
        'audio_path': null,
        'image_path': null,
        'example_phrase': c.$3,
      });
    }

    await db.insert('quiz_questions', {
      'lesson_id': lesson3Id,
      'question': '¿Qué color es "jatse" en Ngigua?',
      'option_a': 'Azul',
      'option_b': 'Amarillo',
      'option_c': 'Verde',
      'option_d': 'Rojo',
      'correct_opt': 'd',
    });
    await db.insert('quiz_questions', {
      'lesson_id': lesson3Id,
      'question': '"rua" significa:',
      'option_a': 'Negro',
      'option_b': 'Blanco / Limpio',
      'option_c': 'Rojo',
      'option_d': 'Verde',
      'correct_opt': 'b',
    });

    // ── LECCIÓN 4: Animales del entorno ───────────────────────────────────────
    final lesson4Id = await db.insert('lessons', {
      'title': 'Animales del entorno',
      'description':
          'Conoce cómo se llaman los animales en Ngigua. '
              'La palabra general para animal es "kuxiigo". '
              'Nota el prefijo "ku-" presente en muchos animales.',
      'category': 'Animales',
      'difficulty': 2,
      'created_at': now,
      'is_example': 1,
    });

    final animales = [
      ('kunia', 'Perro'),
      ('kumichin', 'Gato'),
      ('kuxijna', 'Venado'),
      ('kunthua', 'Pájaro'),
      ('kukapio', 'Mariposa'),
    ];

    for (final a in animales) {
      await db.insert('words', {
        'lesson_id': lesson4Id,
        'indigenous_word': a.$1,
        'translation': a.$2,
        'audio_path': null,
        'image_path': null,
        'example_phrase': null,
      });
    }

    await db.insert('quiz_questions', {
      'lesson_id': lesson4Id,
      'question': '¿Cómo se dice "Perro" en Ngigua?',
      'option_a': 'kumichin',
      'option_b': 'kuxijna',
      'option_c': 'kunia',
      'option_d': 'kunthua',
      'correct_opt': 'c',
    });

    // ── LECCIÓN 5: La familia ─────────────────────────────────────────────────
    final lesson5Id = await db.insert('lessons', {
      'title': 'La familia',
      'description':
          'Aprende los términos de parentesco en Ngigua. '
              'La familia ("nichoo") es el núcleo de la organización social '
              'de San Marcos Tlacoyalco.',
      'category': 'Familia',
      'difficulty': 3,
      'created_at': now,
      'is_example': 1,
    });

    final familia = [
      ('ndudaa', 'Padre / Papá'),
      ('jannaa', 'Madre / Mamá'),
      ('choo', 'Hermano / Hermana'),
      ('nichoo', 'Familia'),
      ('junchjan', 'Anciano / Anciana (con respeto)'),
    ];

    for (final f in familia) {
      await db.insert('words', {
        'lesson_id': lesson5Id,
        'indigenous_word': f.$1,
        'translation': f.$2,
        'audio_path': null,
        'image_path': null,
        'example_phrase': null,
      });
    }

    await db.insert('quiz_questions', {
      'lesson_id': lesson5Id,
      'question': '"jannaa" en Ngigua significa:',
      'option_a': 'Padre',
      'option_b': 'Abuelo',
      'option_c': 'Madre / Mamá',
      'option_d': 'Hermano',
      'correct_opt': 'c',
    });
  }
}
