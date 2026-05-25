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
      'order_index': 1,
      'is_locked': 0,
      'is_completed': 0,
    });

    final saludos = [
      ('deo',    'Saludo al encontrar a alguien', 'assets/images/saludo_deo.jpg',    'Deo — se dice al cruzarse con alguien en el camino',   'assets/audio/saludo_1.mp3'),
      ('jian',   'Bien / Bueno',                  'assets/images/saludo_jian.jpg',   'Jian — estoy bien',                                   'assets/audio/saludo_2.mp3'),
      ('jaro',   'Bonito / De buen carácter',     'assets/images/saludo_jaro.jpg',   'Jaro — es una persona de buen carácter',               'assets/audio/saludo_3.mp3'),
      ('chee',   'Estar alegre / contento',       'assets/images/saludo_chee.jpg',   'Chéna — yo estoy alegre',                             'assets/audio/saludo_4.mp3'),
      ('juajna', 'Saludo / Mensaje',              'assets/images/saludo_juajna.jpg', 'Juajna — un mensaje de saludo',                       'assets/audio/saludo_5.mp3'),
    ];
    for (final s in saludos) {
      await db.insert('words', {
        'lesson_id': lesson1Id,
        'indigenous_word': s.$1,
        'translation': s.$2,
        'audio_path': s.$5,
        'image_path': s.$3,
        'example_phrase': s.$4,
      });
    }
    for (final q in [..._q1(lesson1Id), ..._q1extra(lesson1Id)]) {
      await db.insert('quiz_questions', q);
    }

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
      'order_index': 2,
      'is_locked': 1,
      'is_completed': 0,
    });

    final numeros = [
      ('naa', 'Uno (1)',    'assets/images/numero_naa.jpg', 'Naa — uno, el primero',           'assets/audio/numero_1.mp3'),
      ('yoo',  'Dos (2)',    'assets/images/numero_yoo.jpg',  'Yoo — dos tortillas',              'assets/audio/numero_2.mp3'),
      ('nii',  'Tres (3)',   'assets/images/numero_nii.jpg',  'Nii — tres días',                  'assets/audio/numero_3.mp3'),
      ('noo',  'Cuatro (4)', 'assets/images/numero_noo.jpg',  'Noo — cuatro pasos',               'assets/audio/numero_4.mp3'),
      ('naꞌo',  'Cinco (5)',  'assets/images/numero_nao.jpg',  'Naꞌo — cinco dedos de la mano',     'assets/audio/numero_5.mp3'),
    ];
    for (final n in numeros) {
      await db.insert('words', {
        'lesson_id': lesson2Id,
        'indigenous_word': n.$1,
        'translation': n.$2,
        'audio_path': n.$5,
        'image_path': n.$3,
        'example_phrase': n.$4,
      });
    }
    for (final q in [..._q2(lesson2Id), ..._q2extra(lesson2Id)]) {
      await db.insert('quiz_questions', q);
    }

    // ── LECCIÓN 3: Colores ────────────────────────────────────────────────────
    final lesson3Id = await db.insert('lessons', {
      'title': 'Colores',
      'description':
          'Aprende los colores básicos en Ngigua. '
          'En Ngigua, la palabra "naꞌo" también significa "color" en general.',
      'category': 'Vocabulario',
      'difficulty': 2,
      'created_at': now,
      'is_example': 1,
      'order_index': 3,
      'is_locked': 1,
      'is_completed': 0,
    });

    final colores = [
      ('jatse', 'Rojo / Colorado', 'assets/images/color_jatse.jpg', 'Ndaxra jatse — mole rojo',       'assets/audio/color_1.mp3'),
      ('yua',   'Verde / Azul',    'assets/images/color_yua.jpg',   'Jnayua — chile verde',            'assets/audio/color_2.mp3'),
      ('rua',   'Blanco / Limpio', 'assets/images/color_rua.jpg',   'Rua — ropa blanca limpia',        'assets/audio/color_3.mp3'),
      ('sine',  'Amarillo',        'assets/images/color_sine.jpg',  'Sine — maíz amarillo',            'assets/audio/color_4.mp3'),
      ('thie',  'Negro / Noche',   'assets/images/color_thie.jpg',  'Thie — la noche oscura',          'assets/audio/color_5.mp3'),
    ];
    for (final c in colores) {
      await db.insert('words', {
        'lesson_id': lesson3Id,
        'indigenous_word': c.$1,
        'translation': c.$2,
        'audio_path': c.$5,
        'image_path': c.$3,
        'example_phrase': c.$4,
      });
    }
    for (final q in [..._q3(lesson3Id), ..._q3extra(lesson3Id)]) {
      await db.insert('quiz_questions', q);
    }

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
      'order_index': 4,
      'is_locked': 1,
      'is_completed': 0,
    });

    final animales = [
      ('kunia',    'Perro',     'assets/images/animal_perro.jpg',    'Kunia — el perro cuida la casa',              'assets/audio/animal_1.mp3'),
      ('kumichin', 'Gato',      'assets/images/animal_gato.jpg',     'Kumichin — el gato caza ratones',             'assets/audio/animal_2.mp3'),
      ('kuxijna',  'Venado',    'assets/images/animal_venado.jpg',   'Kuxijna — el venado corre en el monte',       'assets/audio/animal_3.mp3'),
      ('kunthua',  'Pájaro',    'assets/images/animal_pajaro.jpg',   'Kunthua — el pájaro canta en la mañana',     'assets/audio/animal_4.mp3'),
      ('kukapio',  'Mariposa',  'assets/images/animal_mariposa.jpg', 'Kukapio — la mariposa vuela entre las flores','assets/audio/animal_5.mp3'),
    ];
    for (final a in animales) {
      await db.insert('words', {
        'lesson_id': lesson4Id,
        'indigenous_word': a.$1,
        'translation': a.$2,
        'audio_path': a.$5,
        'image_path': a.$3,
        'example_phrase': a.$4,
      });
    }
    for (final q in [..._q4(lesson4Id), ..._q4extra(lesson4Id)]) {
      await db.insert('quiz_questions', q);
    }

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
      'order_index': 5,
      'is_locked': 1,
      'is_completed': 0,
    });

    final familia = [
      ('ndudaa',   'Padre / Papá',               'assets/images/familia_ndudaa.jpg',   'Ndudaa — mi papá trabaja la milpa',             'assets/audio/familia_1.mp3'),
      ('jannaa',   'Madre / Mamá',               'assets/images/familia_jannaa.jpg',   'Jannaa — mi mamá hace tortillas',               'assets/audio/familia_2.mp3'),
      ('choo',     'Hermano / Hermana',           'assets/images/familia_choo.jpg',     'Choo — mi hermano me ayuda',                    'assets/audio/familia_3.mp3'),
      ('nichoo',   'Familia',                     'assets/images/familia_nichoo.jpg',   'Nichoo — toda la familia se reúne',             'assets/audio/familia_4.mp3'),
      ('junchjan', 'Anciano / Anciana (respeto)', 'assets/images/familia_junchjan.jpg', 'Junchjan — el anciano sabe muchas historias',   'assets/audio/familia_5.mp3'),
    ];
    for (final f in familia) {
      await db.insert('words', {
        'lesson_id': lesson5Id,
        'indigenous_word': f.$1,
        'translation': f.$2,
        'audio_path': f.$5,
        'image_path': f.$3,
        'example_phrase': f.$4,
      });
    }
    for (final q in [..._q5(lesson5Id), ..._q5extra(lesson5Id)]) {
      await db.insert('quiz_questions', q);
    }

    // ── LECCIÓN 6: El cuerpo humano ───────────────────────────────────────────
    final lesson6Id = await db.insert('lessons', {
      'title': 'El cuerpo humano',
      'description':
          'Aprende las partes del cuerpo en Ngigua. '
          'Conocer el vocabulario del cuerpo te ayudará a describir '
          'sensaciones y enfermedades.',
      'category': 'Cuerpo',
      'difficulty': 2,
      'created_at': now,
      'is_example': 1,
      'order_index': 6,
      'is_locked': 1,
      'is_completed': 0,
    });

    final cuerpo = [
      ('jaa',       'Cabeza', 'assets/images/cuerpo_jaa.jpg',       'Jaa — me duele la cabeza',                    'assets/audio/cuerpo_1.mp3'),
      ('jmakon',    'Ojo',    'assets/images/cuerpo_jmakon.jpg',    'Jmakon — tengo los ojos cansados',            'assets/audio/cuerpo_2.mp3'),
      ('chinthjon', 'Nariz',  'assets/images/cuerpo_chinthjon.jpg', 'Chinthjon — me duele la nariz',               'assets/audio/cuerpo_3.mp3'),
      ('rua',       'Boca',   'assets/images/cuerpo_rua.jpg',       'Rua — abro la boca para hablar',              'assets/audio/cuerpo_4.mp3'),
      ('raa',       'Mano',   'assets/images/cuerpo_raa.jpg',       'Raa — lavo mis manos',                        'assets/audio/cuerpo_5.mp3'),
      ('ruthea',    'Pie',    'assets/images/cuerpo_ruthea.jpg',    'Ruthea — camino con los pies',                'assets/audio/cuerpo_6.mp3'),
      ('neje',      'Lengua', 'assets/images/cuerpo_neje.jpg',      'Neje — la lengua sirve para hablar y comer',  'assets/audio/cuerpo_7.mp3'),
      ('thusin',    'Cuello', 'assets/images/cuerpo_thusin.jpg',    'Thusin — traigo algo al cuello',              'assets/audio/cuerpo_8.mp3'),
    ];
    for (final c in cuerpo) {
      await db.insert('words', {
        'lesson_id': lesson6Id,
        'indigenous_word': c.$1,
        'translation': c.$2,
        'audio_path': c.$5,
        'image_path': c.$3,
        'example_phrase': c.$4,
      });
    }
    for (final q in [..._q6(lesson6Id), ..._q6extra(lesson6Id)]) {
      await db.insert('quiz_questions', q);
    }

    // ── LECCIÓN 7: Alimentos y bebidas ────────────────────────────────────────
    final lesson7Id = await db.insert('lessons', {
      'title': 'Alimentos y bebidas',
      'description':
          'Aprende el vocabulario de alimentos tradicionales en Ngigua. '
          'La tortilla ("nio") y el maíz ("nua") son la base de la '
          'alimentación en San Marcos Tlacoyalco.',
      'category': 'Alimentos',
      'difficulty': 2,
      'created_at': now,
      'is_example': 1,
      'order_index': 7,
      'is_locked': 1,
      'is_completed': 0,
    });

    final alimentos = [
      ('nio',       'Tortilla',        'assets/images/alimento_nio.jpg',       'Nio — hago tortillas en el comal',             'assets/audio/alimento_1.mp3'),
      ('nua',       'Maíz / Milpa',    'assets/images/alimento_nua.jpg',       'Nua — el maíz es nuestra vida',               'assets/audio/alimento_2.mp3'),
      ('niunthao', 'Tamal',           'assets/images/alimento_niunthao.jpg', 'Niunthao — los tamales son para la fiesta',   'assets/audio/alimento_3.mp3'),
      ('thukma',    'Papa',            'assets/images/alimento_thukma.jpg',    'Thukma — la papa crece en la milpa',           'assets/audio/alimento_4.mp3'),
      ('thuchmoin', 'Fruta',           'assets/images/alimento_thuchmoin.jpg', 'Thuchmoin — como fruta del árbol',             'assets/audio/alimento_5.mp3'),
      ('ndaxra',    'Comida / Mole',   'assets/images/alimento_ndaxra.jpg',    'Ndaxra — la comida está lista',               'assets/audio/alimento_6.mp3'),
      ('tumi',      'Dinero / Moneda', 'assets/images/alimento_tumi.jpg',      'Tumi — con el dinero compramos comida',        'assets/audio/alimento_7.mp3'),
    ];
    for (final a in alimentos) {
      await db.insert('words', {
        'lesson_id': lesson7Id,
        'indigenous_word': a.$1,
        'translation': a.$2,
        'audio_path': a.$5,
        'image_path': a.$3,
        'example_phrase': a.$4,
      });
    }
    for (final q in [..._q7(lesson7Id), ..._q7extra(lesson7Id)]) {
      await db.insert('quiz_questions', q);
    }

    // ── LECCIÓN 8: Verbos básicos ─────────────────────────────────────────────
    final lesson8Id = await db.insert('lessons', {
      'title': 'Verbos básicos',
      'description':
          'Aprende los verbos más usados en el día a día en Ngigua. '
          'Los verbos te permiten expresar acciones cotidianas.',
      'category': 'Verbos',
      'difficulty': 3,
      'created_at': now,
      'is_example': 1,
      'order_index': 8,
      'is_locked': 1,
      'is_completed': 0,
    });

    final verbos = [
      ('nichma',  'Hablar',  'assets/images/verbo_nichma.jpg',  'Nichma Ngigua — habla en Ngigua',   'assets/audio/verbo_1.mp3'),
      ('thji',    'Ir',      'assets/images/verbo_thji.jpg',    'Thji — voy al mercado',             'assets/audio/verbo_2.mp3'),
      ('thii',    'Venir',   'assets/images/verbo_thii.jpg',    'Thii — ven aquí',                   'assets/audio/verbo_3.mp3'),
      ('tsjee',   'Mirar',   'assets/images/verbo_tsjee.jpg',   'Tsjee — mira el cielo',             'assets/audio/verbo_4.mp3'),
      ('thjen',   'Lavar',   'assets/images/verbo_thjen.jpg',   'Thjen raa — lavar las manos',       'assets/audio/verbo_5.mp3'),
      ('tsmjan',  'Reír',    'assets/images/verbo_tsmjan.jpg',  'Tsmjan — reír es bueno',            'assets/audio/verbo_6.mp3'),
      ('tsmjang', 'Llorar',  'assets/images/verbo_tsmjang.jpg', 'Tsmjang — el niño llora',           'assets/audio/verbo_7.mp3'),
      ('ruchrin', 'Brincar', 'assets/images/verbo_ruchrin.jpg', 'Ruchrin — los niños brincan',       'assets/audio/verbo_8.mp3'),
    ];
    for (final v in verbos) {
      await db.insert('words', {
        'lesson_id': lesson8Id,
        'indigenous_word': v.$1,
        'translation': v.$2,
        'audio_path': v.$5,
        'image_path': v.$3,
        'example_phrase': v.$4,
      });
    }
    for (final q in [..._q8(lesson8Id), ..._q8extra(lesson8Id)]) {
      await db.insert('quiz_questions', q);
    }

    // ── LECCIÓN 9: La casa y sus objetos ──────────────────────────────────────
    final lesson9Id = await db.insert('lessons', {
      'title': 'La casa y sus objetos',
      'description':
          'Aprende el vocabulario de la casa y el hogar en Ngigua. '
          'La casa ("nchian") es el corazón de la vida familiar '
          'en San Marcos Tlacoyalco.',
      'category': 'Casa',
      'difficulty': 3,
      'created_at': now,
      'is_example': 1,
      'order_index': 9,
      'is_locked': 1,
      'is_completed': 0,
    });

    final casa = [
      ('nchian', 'Casa',           'assets/images/casa_nchian.jpg', 'Nchian — mi casa es pequeña pero bonita', 'assets/audio/casa_1.mp3'),
      ('nuxra',  'Cobija / Tela',  'assets/images/casa_nuxra.jpg',  'Nuxra — la cobija abriga en el frío',     'assets/audio/casa_2.mp3'),
      ('xrui',   'Fuego / Lumbre', 'assets/images/casa_xrui.jpg',   'Xrui — el fuego calienta el hogar',       'assets/audio/casa_3.mp3'),
      ('nthaa',  'Árbol / Madera', 'assets/images/casa_nthaa.jpg',  'Nthaa — la madera sirve para construir',  'assets/audio/casa_4.mp3'),
      ('xro',    'Piedra',         'assets/images/casa_xro.jpg',    'Xro — las piedras forman las paredes',    'assets/audio/casa_5.mp3'),
      ('xroon',  'Papel / Hoja',   'assets/images/casa_xroon.jpg',  'Xroon — el papel para escribir',          'assets/audio/casa_6.mp3'),
      ('nunthe', 'Tierra / Suelo', 'assets/images/casa_nunthe.jpg', 'Nunthe — la tierra donde vivimos',        'assets/audio/casa_7.mp3'),
      ('xra',    'Trabajo',        'assets/images/casa_xra.jpg',    'Xra — el trabajo es digno',               'assets/audio/casa_8.mp3'),
    ];
    for (final c in casa) {
      await db.insert('words', {
        'lesson_id': lesson9Id,
        'indigenous_word': c.$1,
        'translation': c.$2,
        'audio_path': c.$5,
        'image_path': c.$3,
        'example_phrase': c.$4,
      });
    }
    for (final q in [..._q9(lesson9Id), ..._q9extra(lesson9Id)]) {
      await db.insert('quiz_questions', q);
    }

    // ── LECCIÓN 10: Ropa y vestimenta ─────────────────────────────────────────
    final lesson10Id = await db.insert('lessons', {
      'title': 'Ropa y vestimenta',
      'description':
          'Aprende el vocabulario de la ropa tradicional en Ngigua. '
          'El rebozo ("ruthe") y el sombrero son prendas emblemáticas '
          'de la región.',
      'category': 'Ropa',
      'difficulty': 3,
      'created_at': now,
      'is_example': 1,
      'order_index': 10,
      'is_locked': 1,
      'is_completed': 0,
    });

    final ropa = [
      ('ruthe',        'Rebozo',             'assets/images/ropa_ruthe.jpg',        'Ruthe — la mujer lleva su rebozo',                'assets/audio/ropa_1.mp3'),
      ('xranchritmja', 'Sombrero',           'assets/images/ropa_xranchritmja.jpg', 'Xranchritmja — el hombre lleva su sombrero',      'assets/audio/ropa_2.mp3'),
      ('ruthe jatse',  'Rebozo rojo',        'assets/images/ropa_ruthe_jatse.jpg',  'Ruthe jatse — el rebozo rojo de la fiesta',       'assets/audio/ropa_3.mp3'),
      ('ruthe thie',   'Rebozo negro',       'assets/images/ropa_ruthe_thie.jpg',   'Ruthe thie — el rebozo negro de luto',            'assets/audio/ropa_4.mp3'),
      ('nuxra rua',    'Tela blanca',        'assets/images/ropa_nuxra_rua.jpg',    'Nuxra rua — la tela blanca del huipil',           'assets/audio/ropa_5.mp3'),
      ('raa ruthe',    'Faja / Cinturón',    'assets/images/ropa_raa_ruthe.jpg',    'Raa ruthe — la faja sujeta la ropa',              'assets/audio/ropa_6.mp3'),
      ('ruthea nuxra', 'Sandalia / Huarache','assets/images/ropa_ruthea_nuxra.jpg', 'Ruthea nuxra — las sandalias para el camino',     'assets/audio/ropa_7.mp3'),
    ];
    for (final r in ropa) {
      await db.insert('words', {
        'lesson_id': lesson10Id,
        'indigenous_word': r.$1,
        'translation': r.$2,
        'audio_path': r.$5,
        'image_path': r.$3,
        'example_phrase': r.$4,
      });
    }
    for (final q in [..._q10(lesson10Id), ..._q10extra(lesson10Id)]) {
      await db.insert('quiz_questions', q);
    }

    // ── LECCIÓN 11: El tiempo y el campo ──────────────────────────────────────
    final lesson11Id = await db.insert('lessons', {
      'title': 'El tiempo y el campo',
      'description':
          'Aprende vocabulario sobre la naturaleza, el tiempo y la milpa '
          'en Ngigua. La relación con la tierra y el campo es central '
          'en la vida de San Marcos Tlacoyalco.',
      'category': 'Naturaleza',
      'difficulty': 3,
      'created_at': now,
      'is_example': 1,
      'order_index': 11,
      'is_locked': 1,
      'is_completed': 0,
    });

    final tiempo = [
      ('nchaon', 'Sol / Día',     'assets/images/tiempo_nchaon.jpg', 'Nchaon — el sol sale por el oriente',          'assets/audio/tiempo_1.mp3'),
      ('chrin',  'Lluvia',        'assets/images/tiempo_chrin.jpg',  'Chrin — cae la lluvia en la milpa',            'assets/audio/tiempo_2.mp3'),
      ('nunthe', 'Tierra',        'assets/images/tiempo_nunthe.jpg', 'Nunthe — la tierra húmeda huele bien',         'assets/audio/tiempo_3.mp3'),
      ('nthaa',  'Monte / Árbol', 'assets/images/tiempo_nthaa.jpg',  'Nthaa — el monte está lleno de árboles',      'assets/audio/tiempo_4.mp3'),
      ('xro',    'Piedra',        'assets/images/tiempo_xro.jpg',    'Xro — las piedras marcan el camino',           'assets/audio/tiempo_5.mp3'),
      ('rajna',  'Pueblo',        'assets/images/tiempo_rajna.jpg',  'Rajna — nuestro pueblo tiene historia',        'assets/audio/tiempo_6.mp3'),
      ('nua',    'Milpa / Maíz',  'assets/images/tiempo_nua.jpg',    'Nua — la milpa crece con la lluvia',           'assets/audio/tiempo_7.mp3'),
      ('xrui',   'Fuego / Calor', 'assets/images/tiempo_xrui.jpg',   'Xrui — el calor del fuego en la noche fría',  'assets/audio/tiempo_8.mp3'),
    ];
    for (final t in tiempo) {
      await db.insert('words', {
        'lesson_id': lesson11Id,
        'indigenous_word': t.$1,
        'translation': t.$2,
        'audio_path': t.$5,
        'image_path': t.$3,
        'example_phrase': t.$4,
      });
    }
    for (final q in [..._q11(lesson11Id), ..._q11extra(lesson11Id)]) {
      await db.insert('quiz_questions', q);
    }

    // ── LECCIÓN 12: Frases del día a día ──────────────────────────────────────
    final lesson12Id = await db.insert('lessons', {
      'title': 'Frases del día a día',
      'description':
          'Aprende frases completas para usar en conversaciones cotidianas '
          'en Ngigua. Con estas frases podrás comunicarte en situaciones '
          'básicas del día a día.',
      'category': 'Frases',
      'difficulty': 4,
      'created_at': now,
      'is_example': 1,
      'order_index': 12,
      'is_locked': 1,
      'is_completed': 0,
    });

    final frases = [
      ('deo',           'Hola / Saludo',                   'assets/images/frase_deo.jpg',           'Deo — se dice al encontrar a alguien',        'assets/audio/frase_1.mp3'),
      ('jian',          'Estoy bien',                      'assets/images/frase_jian.jpg',          'Jian — respuesta al saludo',                  'assets/audio/frase_2.mp3'),
      ('thji',          'Vamos',                           'assets/images/frase_thji.jpg',          'Thji — vamos a la milpa',                     'assets/audio/frase_3.mp3'),
      ('nthii',         'Aquí',                            'assets/images/frase_nthii.jpg',         'Nthii — estoy aquí',                          'assets/audio/frase_4.mp3'),
      ('nthia',         'Allá',                            'assets/images/frase_nthia.jpg',         'Nthia — está allá',                           'assets/audio/frase_5.mp3'),
      ('jian nchaon',   'Buenos días (lit. buen sol)',     'assets/images/frase_jian_nchaon.jpg',   'Jian nchaon — buenos días',                   'assets/audio/frase_6.mp3'),
      ('nichma Ngigua', 'Habla Ngigua / Habla en Ngigua', 'assets/images/frase_nichma_ngigua.jpg', 'Nichma Ngigua — habla nuestra lengua',         'assets/audio/frase_7.mp3'),
    ];
    for (final f in frases) {
      await db.insert('words', {
        'lesson_id': lesson12Id,
        'indigenous_word': f.$1,
        'translation': f.$2,
        'audio_path': f.$5,
        'image_path': f.$3,
        'example_phrase': f.$4,
      });
    }
    for (final q in [..._q12(lesson12Id), ..._q12extra(lesson12Id)]) {
      await db.insert('quiz_questions', q);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Preguntas de quiz — 15 por lección (10 base + 5 extra)
  // ══════════════════════════════════════════════════════════════════════════

  static List<Map<String, dynamic>> _q1(int lessonId) => [
        _q(lessonId, '¿Cómo se saluda al encontrar a alguien en Ngigua?',
            'deo', 'jian', 'chee', 'juajna', 'a'),
        _q(lessonId, '¿Qué significa "jian" en Ngigua?',
            'Triste', 'Bien / Bueno', 'Saludo', 'Enojado', 'b'),
        _q(lessonId, '"chee" en Ngigua significa:',
            'Estar cansado', 'Estar enojado', 'Estar alegre / contento', 'Estar enfermo', 'c'),
        _q(lessonId, '¿Qué significa "jaro"?',
            'Triste', 'Enfermo', 'Bonito / De buen carácter', 'Saludo', 'c'),
        _q(lessonId, '"juajna" en Ngigua es:',
            'Número uno', 'Saludo / Mensaje', 'Color rojo', 'Agua', 'b'),
        _q(lessonId, '¿Cuál de estas palabras es un saludo en Ngigua?',
            'naꞌo', 'rua', 'deo', 'nthaa', 'c'),
        _q(lessonId, 'Si respondes "jian" cuando te preguntan cómo estás, ¿qué dices?',
            'Estoy triste', 'Estoy cansado', 'Estoy bien', 'Tengo hambre', 'c'),
        _q(lessonId, '¿Cuál NO es un saludo o expresión de bienestar en Ngigua?',
            'deo', 'jian', 'chee', 'nuo', 'd'),
        _q(lessonId, '¿Qué expresa "Chéna" en Ngigua?',
            'Tengo hambre', 'Estoy bien', 'Yo estoy alegre', 'Hasta luego', 'c'),
        _q(lessonId, '"jaro" describe a una persona:',
            'Enojada', 'De buen carácter', 'Triste', 'Cansada', 'b'),
      ];

  static List<Map<String, dynamic>> _q2(int lessonId) => [
        _q(lessonId, '¿Cómo se dice "Uno" en Ngigua?',
            'yoo', 'naꞌo', 'naa', 'nii', 'c'),
        _q(lessonId, '"noo" es el número:',
            'Tres', 'Cuatro', 'Cinco', 'Dos', 'b'),
        _q(lessonId, '¿Cuál es el número 2 en Ngigua?',
            'nii', 'naa', 'yoo', 'naꞌo', 'c'),
        _q(lessonId, '"nii" en Ngigua significa:',
            'Uno', 'Dos', 'Tres', 'Cuatro', 'c'),
        _q(lessonId, '¿Cómo se dice "Cinco" en Ngigua?',
            'noo', 'naꞌo', 'naa', 'yoo', 'b'),
        _q(lessonId, '¿Qué número es "naa"?',
            '2', '5', '3', '1', 'd'),
        _q(lessonId, '¿Cuál es el orden correcto de los números en Ngigua?',
            'naꞌo, nii, yoo, naa, noo', 'naa, yoo, nii, noo, naꞌo',
            'noo, naꞌo, naa, yoo, nii', 'nii, naꞌo, naa, yoo, noo', 'b'),
        _q(lessonId, '"yoo" en Ngigua es el número:',
            'Uno', 'Dos', 'Cuatro', 'Cinco', 'b'),
        _q(lessonId, 'Si tienes "nii" tortillas, ¿cuántas tienes?',
            '1', '2', '3', '5', 'c'),
        _q(lessonId, '¿Cuál NO es un número en Ngigua?',
            'naa', 'yoo', 'deo', 'naꞌo', 'c'),
      ];

  static List<Map<String, dynamic>> _q3(int lessonId) => [
        _q(lessonId, '¿Qué color es "jatse" en Ngigua?',
            'Azul', 'Amarillo', 'Verde', 'Rojo', 'd'),
        _q(lessonId, '"rua" significa:',
            'Negro', 'Blanco / Limpio', 'Rojo', 'Verde', 'b'),
        _q(lessonId, '¿Cómo se dice "Verde / Azul" en Ngigua?',
            'jatse', 'sine', 'yua', 'thie', 'c'),
        _q(lessonId, '"thie" en Ngigua es:',
            'Amarillo', 'Blanco', 'Verde', 'Negro / Noche', 'd'),
        _q(lessonId, '¿Qué color es "sine"?',
            'Rojo', 'Amarillo', 'Negro', 'Blanco', 'b'),
        _q(lessonId, '¿Cuál de estos colores describe la noche?',
            'jatse', 'sine', 'rua', 'thie', 'd'),
        _q(lessonId, 'El mole rojo ("ndaxra jatse") usa el color:',
            'yua', 'jatse', 'rua', 'sine', 'b'),
        _q(lessonId, '"Jnayua" es el chile:',
            'Rojo', 'Negro', 'Verde', 'Amarillo', 'c'),
        _q(lessonId, '¿Qué color es "rua" en Ngigua?',
            'Rojo', 'Verde', 'Blanco / Limpio', 'Negro', 'c'),
        _q(lessonId, '¿Cuál NO es un color en esta lección?',
            'jatse', 'yua', 'deo', 'sine', 'c'),
      ];

  static List<Map<String, dynamic>> _q4(int lessonId) => [
        _q(lessonId, '¿Cómo se dice "Perro" en Ngigua?',
            'kumichin', 'kuxijna', 'kunia', 'kunthua', 'c'),
        _q(lessonId, '"kumichin" en Ngigua es:',
            'Perro', 'Gato', 'Pájaro', 'Venado', 'b'),
        _q(lessonId, '¿Cuál es el animal que corre en el monte?',
            'kukapio', 'kunia', 'kuxijna', 'kumichin', 'c'),
        _q(lessonId, '"kunthua" en Ngigua significa:',
            'Mariposa', 'Pájaro', 'Gato', 'Venado', 'b'),
        _q(lessonId, '¿Cómo se dice "Mariposa" en Ngigua?',
            'kunia', 'kuxijna', 'kunthua', 'kukapio', 'd'),
        _q(lessonId, '¿Qué animal cuida la casa?',
            'kumichin', 'kuxijna', 'kunia', 'kukapio', 'c'),
        _q(lessonId, '¿Cuál de estos animales vuela entre las flores?',
            'kunia', 'kumichin', 'kuxijna', 'kukapio', 'd'),
        _q(lessonId, 'El prefijo "ku-" en Ngigua aparece en:',
            'Solo en "kunia"', 'Solo en animales grandes',
            'Muchos nombres de animales', 'Solo en pájaros', 'c'),
        _q(lessonId, '"kuxijna" en Ngigua es:',
            'Perro', 'Gato', 'Mariposa', 'Venado', 'd'),
        _q(lessonId, '¿Cuál NO es un animal en Ngigua?',
            'kunia', 'kumichin', 'jatse', 'kuxijna', 'c'),
      ];

  static List<Map<String, dynamic>> _q5(int lessonId) => [
        _q(lessonId, '"jannaa" en Ngigua significa:',
            'Padre', 'Abuelo', 'Madre / Mamá', 'Hermano', 'c'),
        _q(lessonId, '¿Cómo se dice "Padre / Papá" en Ngigua?',
            'jannaa', 'choo', 'ndudaa', 'nichoo', 'c'),
        _q(lessonId, '"nichoo" en Ngigua es:',
            'Hermano', 'Familia', 'Padre', 'Anciano', 'b'),
        _q(lessonId, '¿Qué significa "junchjan"?',
            'Hermano', 'Padre', 'Anciano / Anciana (respeto)', 'Familia', 'c'),
        _q(lessonId, '"choo" en Ngigua significa:',
            'Familia', 'Padre', 'Madre', 'Hermano / Hermana', 'd'),
        _q(lessonId, '¿Cómo se llama la familia en Ngigua?',
            'choo', 'nichoo', 'ndudaa', 'junchjan', 'b'),
        _q(lessonId, '¿Qué palabra describe al que tiene más respeto y experiencia?',
            'jannaa', 'choo', 'ndudaa', 'junchjan', 'd'),
        _q(lessonId, '"ndudaa" en Ngigua es el:',
            'Hermano', 'Abuelo', 'Padre', 'Anciano', 'c'),
        _q(lessonId, 'Mi "choo" en Ngigua es mi:',
            'Papá', 'Mamá', 'Hermano o Hermana', 'Familia', 'c'),
        _q(lessonId, '¿Cuál NO es un término de parentesco en esta lección?',
            'ndudaa', 'jannaa', 'choo', 'jatse', 'd'),
      ];

  static List<Map<String, dynamic>> _q6(int lessonId) => [
        _q(lessonId, '¿Cómo se dice "Cabeza" en Ngigua?',
            'raa', 'jaa', 'neje', 'thusin', 'b'),
        _q(lessonId, '"raa" en Ngigua es:',
            'Pie', 'Cuello', 'Mano', 'Ojo', 'c'),
        _q(lessonId, '¿Cuál es la parte del cuerpo que sirve para hablar y comer?',
            'jaa', 'jmakon', 'neje', 'thusin', 'c'),
        _q(lessonId, '"jmakon" en Ngigua significa:',
            'Nariz', 'Ojo', 'Boca', 'Oreja', 'b'),
        _q(lessonId, '¿Cómo se dice "Pie" en Ngigua?',
            'raa', 'neje', 'ruthea', 'thusin', 'c'),
        _q(lessonId, '"chinthjon" en Ngigua es:',
            'Boca', 'Ojo', 'Nariz', 'Cuello', 'c'),
        _q(lessonId, '¿Qué es "thusin" en Ngigua?',
            'Cabeza', 'Mano', 'Pie', 'Cuello', 'd'),
        _q(lessonId, '¿Cómo se dice "Boca" en Ngigua?',
            'jaa', 'jmakon', 'rua', 'thusin', 'c'),
        _q(lessonId, '"ruthea" en Ngigua es:',
            'Mano', 'Pie', 'Nariz', 'Cuello', 'b'),
        _q(lessonId, '¿Con qué parte del cuerpo ("raa") lavas?',
            'Los pies', 'Los ojos', 'Las manos', 'La nariz', 'c'),
      ];

  static List<Map<String, dynamic>> _q7(int lessonId) => [
        _q(lessonId, '¿Cómo se dice "Tortilla" en Ngigua?',
            'nua', 'nio', 'ndaxra', 'tumi', 'b'),
        _q(lessonId, '"nua" en Ngigua significa:',
            'Tamal', 'Tortilla', 'Maíz / Milpa', 'Papa', 'c'),
        _q(lessonId, '¿Cuál es el alimento de fiesta en Ngigua?',
            'nio', 'thukma', 'niunthao', 'ndaxra', 'c'),
        _q(lessonId, '"thukma" en Ngigua es:',
            'Tortilla', 'Papa', 'Fruta', 'Maíz', 'b'),
        _q(lessonId, '¿Qué significa "ndaxra"?',
            'Agua', 'Sal', 'Comida / Mole', 'Tamal', 'c'),
        _q(lessonId, '"tumi" en Ngigua es:',
            'Comida', 'Dinero / Moneda', 'Fruta', 'Tortilla', 'b'),
        _q(lessonId, '¿Cómo se dice "Fruta" en Ngigua?',
            'nio', 'nua', 'thukma', 'thuchmoin', 'd'),
        _q(lessonId, '"niunthao" en Ngigua es:',
            'Papa', 'Tortilla', 'Tamal', 'Fruta', 'c'),
        _q(lessonId, '¿Cuál es la base de la alimentación en San Marcos Tlacoyalco?',
            'thukma', 'nio y nua', 'tumi', 'thuchmoin', 'b'),
        _q(lessonId, '¿Cuál NO es un alimento en esta lección?',
            'nio', 'nua', 'niunthao', 'chrin', 'd'),
      ];

  static List<Map<String, dynamic>> _q8(int lessonId) => [
        _q(lessonId, '¿Cómo se dice "Hablar" en Ngigua?',
            'thji', 'tsjee', 'nichma', 'thjen', 'c'),
        _q(lessonId, '"thji" en Ngigua significa:',
            'Venir', 'Ir', 'Mirar', 'Lavar', 'b'),
        _q(lessonId, '¿Cuál es el verbo "Mirar" en Ngigua?',
            'nichma', 'tsjee', 'thii', 'ruchrin', 'b'),
        _q(lessonId, '"thii" en Ngigua es:',
            'Ir', 'Llorar', 'Venir', 'Brincar', 'c'),
        _q(lessonId, '¿Cómo se dice "Lavar" en Ngigua?',
            'tsmjan', 'thjen', 'ruchrin', 'thji', 'b'),
        _q(lessonId, '"tsmjan" en Ngigua significa:',
            'Llorar', 'Brincar', 'Reír', 'Mirar', 'c'),
        _q(lessonId, '¿Qué verbo describe lo que hacen los niños cuando están tristes?',
            'tsmjan', 'ruchrin', 'tsmjang', 'nichma', 'c'),
        _q(lessonId, '"ruchrin" en Ngigua es:',
            'Reír', 'Llorar', 'Mirar', 'Brincar', 'd'),
        _q(lessonId, '"Nichma Ngigua" significa:',
            'Ir a la milpa', 'Habla en Ngigua', 'Lavar los pies', 'Mirar el sol', 'b'),
        _q(lessonId, '¿Cuál NO es un verbo en esta lección?',
            'thji', 'thii', 'tsjee', 'nio', 'd'),
      ];

  static List<Map<String, dynamic>> _q9(int lessonId) => [
        _q(lessonId, '¿Cómo se dice "Casa" en Ngigua?',
            'nuxra', 'nchian', 'xrui', 'nunthe', 'b'),
        _q(lessonId, '"xrui" en Ngigua significa:',
            'Piedra', 'Tierra', 'Fuego / Lumbre', 'Cobija', 'c'),
        _q(lessonId, '¿Qué es "nuxra" en Ngigua?',
            'Trabajo', 'Árbol', 'Cobija / Tela', 'Papel', 'c'),
        _q(lessonId, '"nthaa" en Ngigua es:',
            'Tierra', 'Piedra', 'Papel', 'Árbol / Madera', 'd'),
        _q(lessonId, '¿Cómo se dice "Piedra" en Ngigua?',
            'xra', 'xroon', 'xro', 'nunthe', 'c'),
        _q(lessonId, '"xroon" en Ngigua significa:',
            'Fuego', 'Papel / Hoja', 'Trabajo', 'Cobija', 'b'),
        _q(lessonId, '¿Qué es "nunthe" en Ngigua?',
            'Casa', 'Piedra', 'Tierra / Suelo', 'Árbol', 'c'),
        _q(lessonId, '"xra" en Ngigua es:',
            'Casa', 'Trabajo', 'Fuego', 'Papel', 'b'),
        _q(lessonId, 'El material para construir ("nthaa") en Ngigua es:',
            'Piedra', 'Fuego', 'Árbol / Madera', 'Tierra', 'c'),
        _q(lessonId, '¿Cuál NO es un objeto o lugar de la casa en esta lección?',
            'nchian', 'xrui', 'nuxra', 'tsmjan', 'd'),
      ];

  static List<Map<String, dynamic>> _q10(int lessonId) => [
        _q(lessonId, '¿Cómo se dice "Rebozo" en Ngigua?',
            'xranchritmja', 'ruthe', 'nuxra rua', 'raa ruthe', 'b'),
        _q(lessonId, '"xranchritmja" en Ngigua es:',
            'Rebozo', 'Sombrero', 'Cinturón', 'Sandalia', 'b'),
        _q(lessonId, '¿Cuál es la prenda de color rojo de la fiesta?',
            'ruthe thie', 'nuxra rua', 'ruthe jatse', 'ruthea nuxra', 'c'),
        _q(lessonId, '"ruthe thie" en Ngigua es:',
            'Rebozo rojo', 'Rebozo negro', 'Tela blanca', 'Sandalia', 'b'),
        _q(lessonId, '¿Qué significa "nuxra rua" en Ngigua?',
            'Rebozo negro', 'Sandalia', 'Tela blanca', 'Faja', 'c'),
        _q(lessonId, '"raa ruthe" en Ngigua es:',
            'Rebozo rojo', 'Sombrero', 'Faja / Cinturón', 'Sandalia', 'c'),
        _q(lessonId, '¿Cómo se llaman las sandalias en Ngigua?',
            'raa ruthe', 'ruthe jatse', 'ruthea nuxra', 'xranchritmja', 'c'),
        _q(lessonId, 'El sombrero ("xranchritmja") lo usa típicamente:',
            'La mujer en la cocina', 'El hombre en el campo',
            'Los niños en la escuela', 'El anciano en la noche', 'b'),
        _q(lessonId, '"ruthe" en Ngigua es:',
            'Sombrero', 'Rebozo', 'Faja', 'Sandalia', 'b'),
        _q(lessonId, '¿Cuál NO es una prenda de vestir en esta lección?',
            'ruthe', 'xranchritmja', 'nchaon', 'raa ruthe', 'c'),
      ];

  static List<Map<String, dynamic>> _q11(int lessonId) => [
        _q(lessonId, '¿Cómo se dice "Sol / Día" en Ngigua?',
            'chrin', 'nchaon', 'nthaa', 'rajna', 'b'),
        _q(lessonId, '"chrin" en Ngigua significa:',
            'Sol', 'Tierra', 'Lluvia', 'Fuego', 'c'),
        _q(lessonId, '¿Qué significa "rajna" en Ngigua?',
            'Monte', 'Tierra', 'Milpa', 'Pueblo', 'd'),
        _q(lessonId, '"nunthe" en esta lección es:',
            'Sol', 'Lluvia', 'Tierra', 'Monte', 'c'),
        _q(lessonId, '¿Cómo se dice "Monte / Árbol" en Ngigua?',
            'xro', 'chrin', 'nthaa', 'rajna', 'c'),
        _q(lessonId, '"nua" en el contexto del campo es:',
            'Lluvia', 'Milpa / Maíz', 'Pueblo', 'Piedra', 'b'),
        _q(lessonId, '"xrui" en el campo se refiere al:',
            'Sol', 'Viento', 'Fuego / Calor', 'Río', 'c'),
        _q(lessonId, '"xro" en Ngigua es:',
            'Árbol', 'Tierra', 'Piedra', 'Fuego', 'c'),
        _q(lessonId, '¿Qué riega la "chrin" en la milpa?',
            'Las piedras', 'El fuego', 'La milpa de maíz', 'El pueblo', 'c'),
        _q(lessonId, '¿Cuál NO es un elemento de la naturaleza en esta lección?',
            'nchaon', 'chrin', 'nunthe', 'tumi', 'd'),
      ];

  static List<Map<String, dynamic>> _q12(int lessonId) => [
        _q(lessonId, '¿Cómo se dice "Hola" en Ngigua?',
            'thji', 'nthii', 'deo', 'nthia', 'c'),
        _q(lessonId, '"thji" en Ngigua significa:',
            'Aquí', 'Allá', 'Vamos', 'Hola', 'c'),
        _q(lessonId, '¿Cómo se dice "Aquí" en Ngigua?',
            'nthia', 'nthii', 'deo', 'jian', 'b'),
        _q(lessonId, '"nthia" en Ngigua es:',
            'Aquí', 'Vamos', 'Allá', 'Hola', 'c'),
        _q(lessonId, '¿Cómo se saluda por la mañana en Ngigua?',
            'nichma Ngigua', 'thji', 'jian nchaon', 'nthii', 'c'),
        _q(lessonId, '"jian nchaon" en Ngigua significa (literalmente):',
            'Buenas noches', 'Buen sol / Buenos días', 'Hasta mañana', 'Vamos al sol', 'b'),
        _q(lessonId, '"nichma Ngigua" significa:',
            'Ir a la milpa', 'Buenos días', 'Habla en Ngigua', 'Estoy aquí', 'c'),
        _q(lessonId, '"jian" al inicio de una respuesta indica:',
            'Que vas a ir', 'Que estás bien', 'Que el lugar está lejos', 'Que ya es de noche', 'b'),
        _q(lessonId, 'Si alguien dice "nthia", ¿a dónde señala?',
            'Aquí cerca', 'Allá lejos', 'Arriba', 'Abajo', 'b'),
        _q(lessonId, '¿Cuál de estas frases usarías para invitar a alguien a acompañarte?',
            'deo', 'jian', 'thji', 'nthia', 'c'),
      ];

  // ══════════════════════════════════════════════════════════════════════════
  // Preguntas extra — 5 adicionales por lección (tipos variados)
  // ══════════════════════════════════════════════════════════════════════════

  static List<Map<String, dynamic>> _q1extra(int lessonId) => [
        _q(lessonId, '¿Qué le dices a alguien en Ngigua cuando te sientes bien?',
            'chee', 'jian', 'jaro', 'deo', 'b'),
        _q(lessonId, 'La palabra "jaro" en Ngigua describe a alguien:',
            'Que trabaja mucho', 'Con buen carácter / bonito', 'Que está cansado', 'Que tiene hambre', 'b'),
        _q(lessonId, '¿Cuál de estas NO es una expresión positiva en Ngigua?',
            'deo', 'jian', 'jaro', 'nii', 'd'),
        _q(lessonId, '"juajna" en Ngigua puede ser:',
            'Una despedida triste', 'Un saludo o mensaje', 'Un número', 'Un color', 'b'),
        _q(lessonId, 'En San Marcos Tlacoyalco, "deo" se usa:',
            'Solo en fiestas', 'Al despedirse', 'Al encontrar a alguien en el camino', 'Solo de noche', 'c'),
      ];

  static List<Map<String, dynamic>> _q2extra(int lessonId) => [
        _q(lessonId, '¿Qué número viene después de "nii" (3) en Ngigua?',
            'naꞌo', 'naa', 'noo', 'yoo', 'c'),
        _q(lessonId, '"naꞌo" en Ngigua son los dedos de la mano. ¿Cuántos son?',
            'Tres', 'Cuatro', 'Cinco', 'Dos', 'c'),
        _q(lessonId, '¿Cómo se dice "Dos" en Ngigua?',
            'noo', 'nii', 'yoo', 'naa', 'c'),
        _q(lessonId, 'La secuencia correcta del 1 al 5 en Ngigua es:',
            'yoo, naa, noo, nii, naꞌo', 'naa, yoo, nii, noo, naꞌo',
            'naꞌo, noo, nii, yoo, naa', 'nii, yoo, naa, naꞌo, noo', 'b'),
        _q(lessonId, 'El sistema numeral del Ngigua tiene base:',
            'Decimal (base 10)', 'Duodecimal (base 12)', 'Vigesimal (base 20)', 'Quinaria (base 5)', 'c'),
      ];

  static List<Map<String, dynamic>> _q3extra(int lessonId) => [
        _q(lessonId, '¿De qué color es el maíz "sine" en Ngigua?',
            'Rojo', 'Verde', 'Amarillo', 'Negro', 'c'),
        _q(lessonId, '"thie" describe el color negro y también:',
            'El fuego', 'El día', 'La noche', 'El agua', 'c'),
        _q(lessonId, '¿Cuál es el color de la ropa limpia ("rua") en Ngigua?',
            'Verde', 'Rojo', 'Negro', 'Blanco', 'd'),
        _q(lessonId, 'El chile verde "jnayua" tiene el color:',
            'Rojo (jatse)', 'Verde / Azul (yua)', 'Amarillo (sine)', 'Negro (thie)', 'b'),
        _q(lessonId, '¿Cuál de estas palabras NO es un color en esta lección?',
            'jatse', 'yua', 'rua', 'nio', 'd'),
      ];

  static List<Map<String, dynamic>> _q4extra(int lessonId) => [
        _q(lessonId, '"kukapio" en Ngigua es:',
            'El pájaro', 'El gato', 'La mariposa', 'El perro', 'c'),
        _q(lessonId, '¿Qué animal canta en la mañana en Ngigua?',
            'kunia', 'kuxijna', 'kunthua', 'kukapio', 'c'),
        _q(lessonId, '¿Cuál de estas palabras NO usa el prefijo "ku-" animal?',
            'kunia', 'kumichin', 'kuxijna', 'thie', 'd'),
        _q(lessonId, 'El venado "kuxijna" en Ngigua vive en:',
            'La casa', 'La milpa', 'El monte', 'El río', 'c'),
        _q(lessonId, 'El animal que caza ratones en Ngigua es:',
            'kunia', 'kumichin', 'kunthua', 'kukapio', 'b'),
      ];

  static List<Map<String, dynamic>> _q5extra(int lessonId) => [
        _q(lessonId, '¿Cómo se dice "Hermano o Hermana" en Ngigua?',
            'ndudaa', 'jannaa', 'choo', 'nichoo', 'c'),
        _q(lessonId, '"junchjan" en Ngigua es respetado porque:',
            'Trabaja la milpa', 'Sabe muchas historias', 'Hace tortillas', 'Cuida la casa', 'b'),
        _q(lessonId, '¿Cuál NO es un miembro de la familia en esta lección?',
            'ndudaa', 'jannaa', 'choo', 'deo', 'd'),
        _q(lessonId, '"nichoo" incluye a todos los miembros de:',
            'El pueblo', 'La familia', 'La milpa', 'La escuela', 'b'),
        _q(lessonId, '¿Cómo llamas a tu mamá en Ngigua?',
            'ndudaa', 'jannaa', 'nichoo', 'choo', 'b'),
      ];

  static List<Map<String, dynamic>> _q6extra(int lessonId) => [
        _q(lessonId, '¿Con qué parte del cuerpo ("neje") pruebas la comida?',
            'jaa (cabeza)', 'jmakon (ojo)', 'neje (lengua)', 'raa (mano)', 'c'),
        _q(lessonId, '"jaa" en Ngigua es la parte con la que piensas:',
            'Las manos', 'Los pies', 'La cabeza', 'La nariz', 'c'),
        _q(lessonId, '¿Cuál parte del cuerpo en Ngigua sirve para ver?',
            'neje', 'jmakon', 'chinthjon', 'thusin', 'b'),
        _q(lessonId, '¿Cómo se dice "Cuello" en Ngigua?',
            'raa', 'ruthea', 'neje', 'thusin', 'd'),
        _q(lessonId, '¿Cuál NO es una parte del cuerpo en esta lección?',
            'jaa', 'raa', 'ruthea', 'chrin', 'd'),
      ];

  static List<Map<String, dynamic>> _q7extra(int lessonId) => [
        _q(lessonId, '"Nua" en Ngigua es la base de la alimentación. ¿Qué es?',
            'La sal', 'El maíz', 'El tamal', 'El dinero', 'b'),
        _q(lessonId, '¿Qué alimento se hace en el comal en Ngigua?',
            'thukma', 'nio', 'niunthao', 'tumi', 'b'),
        _q(lessonId, '¿Cuál NO es un alimento en esta lección?',
            'nio', 'nua', 'niunthao', 'xro', 'd'),
        _q(lessonId, '¿Con qué ("tumi") se compra comida en Ngigua?',
            'Con maíz', 'Con tortillas', 'Con dinero', 'Con fruta', 'c'),
        _q(lessonId, '¿Qué alimento es el especial de las fiestas?',
            'thukma', 'ndaxra', 'niunthao', 'nio', 'c'),
      ];

  static List<Map<String, dynamic>> _q8extra(int lessonId) => [
        _q(lessonId, '"Tsjee nthaa" en Ngigua significa:',
            'Lavar el árbol', 'Ir al monte', 'Mirar el árbol', 'Brincar el árbol', 'c'),
        _q(lessonId, '¿Cuál es el verbo que usas para invitar a alguien a salir?',
            'thii', 'tsjee', 'thji', 'thjen', 'c'),
        _q(lessonId, '¿Cuál NO es un verbo en esta lección?',
            'thji', 'thii', 'nichma', 'nthaa', 'd'),
        _q(lessonId, '"Thjen raa" en Ngigua significa:',
            'Caminar a mano', 'Mirar las manos', 'Lavar las manos', 'Hablar con las manos', 'c'),
        _q(lessonId, 'El verbo "tsmjang" describe una emoción de:',
            'Alegría', 'Tristeza', 'Enojo', 'Sorpresa', 'b'),
      ];

  static List<Map<String, dynamic>> _q9extra(int lessonId) => [
        _q(lessonId, '¿De qué material ("nthaa") se construyen algunas casas?',
            'De piedra', 'De árbol / Madera', 'De tierra', 'De papel', 'b'),
        _q(lessonId, '"Xroon" en Ngigua es el material para:',
            'Construir casas', 'Calentar el hogar', 'Escribir', 'Tejer cobijas', 'c'),
        _q(lessonId, '¿Cuál NO es un material o elemento de la casa?',
            'xrui', 'nthaa', 'xro', 'tsmjan', 'd'),
        _q(lessonId, '"Nunthe" en Ngigua es:',
            'La casa', 'La cobija', 'La tierra / suelo', 'La madera', 'c'),
        _q(lessonId, 'El trabajo ("xra") en San Marcos Tlacoyalco es considerado:',
            'Una carga difícil', 'Algo innecesario', 'Digno y honorable', 'Solo para hombres', 'c'),
      ];

  static List<Map<String, dynamic>> _q10extra(int lessonId) => [
        _q(lessonId, '¿Qué prenda lleva la mujer Ngigua sobre los hombros?',
            'xranchritmja', 'ruthe', 'ruthea nuxra', 'raa ruthe', 'b'),
        _q(lessonId, '"Ruthe jatse" combina rebozo con el color:',
            'Negro', 'Blanco', 'Rojo', 'Verde', 'c'),
        _q(lessonId, '¿Cuál NO es una prenda de vestir en esta lección?',
            'ruthe', 'xranchritmja', 'nunthe', 'raa ruthe', 'c'),
        _q(lessonId, '"Ruthea nuxra" en Ngigua son:',
            'Las fajas de tela', 'El rebozo blanco', 'Las sandalias para el camino', 'El sombrero de palma', 'c'),
        _q(lessonId, 'El rebozo negro ("ruthe thie") se usa especialmente en:',
            'Fiestas', 'Trabajo en la milpa', 'Luto o duelo', 'Lluvia', 'c'),
      ];

  static List<Map<String, dynamic>> _q11extra(int lessonId) => [
        _q(lessonId, '"Nchaon" en Ngigua sale por el:',
            'Poniente', 'Norte', 'Oriente', 'Sur', 'c'),
        _q(lessonId, '¿Qué elemento de la naturaleza riega la milpa?',
            'xrui (fuego)', 'xro (piedra)', 'chrin (lluvia)', 'rajna (pueblo)', 'c'),
        _q(lessonId, '¿Cuál NO es un elemento del campo o la naturaleza?',
            'nchaon', 'chrin', 'xro', 'ruthe', 'd'),
        _q(lessonId, '"Rajna" en Ngigua es el lugar donde vive una comunidad:',
            'La milpa', 'La montaña', 'El pueblo', 'El río', 'c'),
        _q(lessonId, 'La milpa ("nua") crece con ayuda de:',
            'El viento', 'La lluvia (chrin)', 'El fuego (xrui)', 'Las piedras (xro)', 'b'),
      ];

  static List<Map<String, dynamic>> _q12extra(int lessonId) => [
        _q(lessonId, '¿Qué frase Ngigua usas al inicio del día?',
            'nthii', 'thji', 'jian nchaon', 'deo', 'c'),
        _q(lessonId, '"Nichma ___" es la invitación a hablar la lengua indígena.',
            'deo', 'nthia', 'Ngigua', 'jian', 'c'),
        _q(lessonId, '¿Cuál NO es una frase del día a día en esta lección?',
            'deo', 'thji', 'nthii', 'kunia', 'd'),
        _q(lessonId, 'Si algo está lejos, dices "___ " en Ngigua.',
            'nthii', 'nthia', 'deo', 'thji', 'b'),
        _q(lessonId, '"Jian nchaon" es buenos días porque "nchaon" significa:',
            'Lluvia', 'Noche', 'Sol / Día', 'Pueblo', 'c'),
      ];

  // Helper para construir un mapa de pregunta
  static Map<String, dynamic> _q(
    int lessonId,
    String question,
    String a,
    String b,
    String c,
    String d,
    String correct,
  ) =>
      {
        'lesson_id': lessonId,
        'question': question,
        'option_a': a,
        'option_b': b,
        'option_c': c,
        'option_d': d,
        'correct_opt': correct,
      };
}
