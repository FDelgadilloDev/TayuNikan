# TayuNikan — Diseño de expansión A1

**Fecha:** 2026-05-22
**Proyecto:** TayuNikan — App educativa para Ngigua (Popoloca) de San Marcos Tlacoyalco
**Alcance:** Alineación al nivel CEFR A1, 12 lecciones completas, examen diagnóstico, desbloqueo secuencial

---

## 1. Contexto y objetivo

TayuNikan actualmente tiene 5 lecciones de ejemplo con 5 palabras y 2–3 preguntas de quiz cada una. El objetivo es expandirla a un currículo A1 completo que cubra los temas fundamentales para un hablante inicial de Ngigua:

- 12 lecciones con 6–8 palabras cada una
- Cada palabra: texto Ngigua + traducción + imagen watercolor + frase de ejemplo
- Cada lección: ≥10 preguntas de quiz
- Examen diagnóstico inicial que desbloquea lecciones según conocimiento previo
- Sistema de desbloqueo estrictamente lineal (lección N+1 se desbloquea al completar N)
- Imágenes visibles en: tarjeta de palabra, preguntas de quiz, examen diagnóstico

---

## 2. Cambios al esquema de base de datos

### 2.1 Migración: versión 1 → 2

Se agregan tres columnas a la tabla `lessons`:

```sql
ALTER TABLE lessons ADD COLUMN order_index  INTEGER NOT NULL DEFAULT 0;
ALTER TABLE lessons ADD COLUMN is_locked    INTEGER NOT NULL DEFAULT 1;
ALTER TABLE lessons ADD COLUMN is_completed INTEGER NOT NULL DEFAULT 0;
```

**Semántica:**
- `order_index`: posición en la secuencia (1 = primera, 12 = última)
- `is_locked = 0`: el estudiante puede acceder a la lección
- `is_locked = 1`: la lección está bloqueada (muestra candado en UI)
- `is_completed = 1`: el estudiante completó el quiz con éxito

**Reglas de negocio:**
- La Lección 1 se crea con `is_locked=0` (siempre disponible)
- Las lecciones 2–12 se crean con `is_locked=1`
- Al completar el quiz de lección N → marcar `is_completed=1` en N y `is_locked=0` en N+1
- El diagnóstico puede marcar N lecciones como `is_completed=1, is_locked=0` en un solo batch

### 2.2 Implementación de la migración

En `DatabaseHelper.onUpgrade`:

```dart
if (oldVersion < 2) {
  await db.execute('ALTER TABLE lessons ADD COLUMN order_index  INTEGER NOT NULL DEFAULT 0');
  await db.execute('ALTER TABLE lessons ADD COLUMN is_locked    INTEGER NOT NULL DEFAULT 1');
  await db.execute('ALTER TABLE lessons ADD COLUMN is_completed INTEGER NOT NULL DEFAULT 0');
  // Desbloquear lección 1 si ya existe
  await db.execute('UPDATE lessons SET is_locked=0, order_index=1 WHERE id=1');
}
```

La migración no destruye datos existentes.

---

## 3. Currículo A1 — 12 lecciones

### Lecciones existentes (ampliadas a ≥10 preguntas)

| # | order_index | Título | Categoría | Palabras | Dificultad |
|---|-------------|--------|-----------|----------|------------|
| 1 | 1 | Saludos básicos | Saludos | deo, jian, jaro, chee, juajna | 1 |
| 2 | 2 | Números del 1 al 5 | Números | jngo, yoo, nii, noo, nao | 1 |
| 3 | 3 | Colores | Vocabulario | jatse, yua, rua, sine, thie | 2 |
| 4 | 4 | Animales del entorno | Animales | kunia, kumichin, kuxijna, kunthua, kukapio | 2 |
| 5 | 5 | La familia | Familia | ndudaa, jannaa, choo, nichoo, junchjan | 3 |

### Lecciones nuevas

| # | order_index | Título | Categoría | Palabras clave | Dificultad |
|---|-------------|--------|-----------|----------------|------------|
| 6 | 6 | El cuerpo humano | Cuerpo | cabeza, ojo, boca, mano, pie, nariz, oreja, diente | 2 |
| 7 | 7 | Alimentos y bebidas | Alimentos | tortilla, maíz, agua, chile, frijol, atole, sal, mole | 2 |
| 8 | 8 | Verbos básicos | Verbos | hablar, comer, caminar, dormir, mirar, escuchar, llegar, dar | 3 |
| 9 | 9 | La casa y sus objetos | Casa | casa, puerta, mesa, silla, fogón, patio, petate, tecomate | 3 |
| 10 | 10 | Ropa y vestimenta | Ropa | camisa, huipil, sombrero, quexquémetl, zapato, cinturón, rebozo | 3 |
| 11 | 11 | El tiempo y el campo | Naturaleza | sol, lluvia, viento, frío, calor, milpa, tierra, río | 3 |
| 12 | 12 | Frases del día a día | Frases | buenos días, ¿cómo te llamas?, gracias, por favor, ¿cuánto cuesta?, vamos, aquí | 4 |

### Estructura uniforme por lección

Cada lección contiene:
- **6–8 palabras**, cada una con:
  - `indigenous_word`: texto en Ngigua
  - `translation`: traducción al español
  - `image_path`: `assets/images/[categoria]_[palabra].jpg` (estilo watercolor)
  - `example_phrase`: oración de ejemplo usando la palabra en contexto
- **≥10 preguntas de quiz**, mezcla de tipos:
  - Palabra Ngigua → traducción (4 opciones de texto)
  - Traducción → palabra Ngigua (4 opciones de texto)
  - Imagen → palabra Ngigua (4 opciones de texto, imagen como pista)
  - Frase incompleta → completar con la palabra correcta
  - ¿Cuál NO pertenece a este grupo? (odd-one-out temático)

---

## 4. Examen diagnóstico

### 4.1 Flujo

```
HomeScreen
  └─ Botón "Diagnóstico de nivel" (visible si diagnosticCompleted=false en SharedPreferences)
        └─ DiagnosticExamScreen
              ├─ 24 preguntas (2 por lección × 12 lecciones)
              ├─ Formato: imagen + 4 opciones de texto
              ├─ Sin botón "volver" (se completa o se cancela explícitamente)
              └─ DiagnosticResultScreen
                    ├─ Lista: lecciones aprobadas ✓ / pendientes 🔒
                    ├─ Mensaje: "Conoces X de 12 temas"
                    └─ Regresa a HomeScreen con estado actualizado
```

### 4.2 Criterio de aprobación por lección

- Cada lección tiene 2 preguntas en el diagnóstico
- **≥1 correcta de 2** → lección "candidata a desbloquearse"
- **0 correctas de 2** → lección falla el diagnóstico

**Regla de secuencia en el resultado final:**
Se recorren las lecciones en orden (1→12). Si una lección falla el diagnóstico, ella y todas las siguientes quedan bloqueadas, incluso si lecciones posteriores fueron aprobadas. Es decir:

- Si el estudiante aprueba 1, 2, 3, falla 4, aprueba 5-8: se desbloquean y completan 1, 2, 3. La lección 4 queda bloqueada. Las lecciones 5-12 quedan bloqueadas aunque se hayan aprobado.
- Si el estudiante aprueba todo (1-12): todas las lecciones quedan desbloqueadas y completadas.

### 4.3 Selección de preguntas para el diagnóstico

- Se seleccionan 2 preguntas al azar por lección desde `quiz_questions` existentes
- Se prefieren preguntas cuya respuesta tenga imagen asociada (para que el diagnóstico sea visual)
- Si no hay suficientes preguntas con imagen, se usan las de solo texto

### 4.4 Persistencia

- `SharedPreferences`: clave `diagnosticCompleted` (bool)
- El usuario puede repetir el diagnóstico desde Configuración → "Reiniciar diagnóstico"
- Repetir el diagnóstico sobrescribe el estado de lecciones con el nuevo resultado

### 4.5 Opcionalidad

- El diagnóstico **no es obligatorio**: el usuario puede cerrarlo y comenzar desde la Lección 1
- Si se salta el diagnóstico, todas las lecciones (salvo la 1) quedan bloqueadas

---

## 5. Sistema de desbloqueo secuencial

### 5.1 Trigger de desbloqueo

Al completar el quiz de una lección con **≥70% de respuestas correctas** (umbral de éxito), desde la pantalla de resultado del quiz:

```dart
// En QuizResultScreen o LessonProvider
await lessonRepo.markCompleted(lessonId);         // is_completed=1
await lessonRepo.unlockNext(currentOrderIndex);   // is_locked=0 en order_index+1
```

### 5.2 LessonRepository — métodos nuevos

```dart
Future<void> markCompleted(int lessonId);
Future<void> unlockNext(int currentOrderIndex);
Future<void> unlockLessons(List<int> lessonIds);     // para diagnóstico batch
Future<List<Lesson>> getLessonsOrdered();             // ORDER BY order_index
```

### 5.3 Modelo Lesson — campos nuevos

```dart
class Lesson {
  // campos existentes...
  final int orderIndex;
  final bool isLocked;
  final bool isCompleted;
}
```

---

## 6. Imágenes

### 6.1 Estilo

- Todas las imágenes en estilo **watercolor** suave (referencia: `EjemploObjetos.PNG` — conejo acuarela pastel)
- Fondo blanco o transparente, trazo suelto, colores desaturados
- Dimensiones recomendadas: mínimo 400×300 px, JPEG

### 6.2 Nomenclatura

```
assets/images/[categoria]_[identificador].jpg
```

Categorías: `saludo_`, `numero_`, `color_`, `animal_`, `familia_`, `cuerpo_`, `alimento_`, `verbo_`, `casa_`, `ropa_`, `tiempo_`, `frase_`

### 6.3 Fuente

- Imágenes descargadas desde **MET Open Access API** (sin límite de tasa, sin copyright)
- Endpoint: `https://collectionapi.metmuseum.org/public/collection/v1/search?q=TERM&medium=Watercolors`
- Campo utilizado: `primaryImageSmall`
- Script de descarga en Python (ya implementado en sesiones anteriores)

### 6.4 Lecciones existentes (25 imágenes ya descargadas)

Las imágenes de las lecciones 1–5 ya están en `assets/images/`. No requieren acción.

### 6.5 Lecciones nuevas (lecciones 6–12)

Aproximadamente 55 imágenes nuevas necesarias (7 lecciones × ~8 palabras). Se descargan con el mismo script Python antes de la implementación.

**Nota sobre vocabulario Ngigua:** Las palabras exactas en Ngigua para las lecciones 6–12 se extraen del archivo `Gramatica ngigua.pdf` durante la fase de implementación del seeder. El spec lista los conceptos en español; el implementador consulta el PDF para las formas Ngigua correctas antes de codificar el seeder.

---

## 7. Cambios a la UI existente

### 7.1 HomeScreen / lista de lecciones

- Lección **completada** (`is_completed=1`): tarjeta con borde verde y ✓
- Lección **disponible** (`is_locked=0, is_completed=0`): tarjeta normal, clickeable
- Lección **bloqueada** (`is_locked=1`): tarjeta gris, ícono 🔒, `onTap` deshabilitado
- Botón "Diagnóstico de nivel" visible si `diagnosticCompleted=false`

### 7.2 WordDetailScreen / tarjeta de palabra

- Imagen watercolor visible en la tarjeta: ~160×120 px
- Si no hay imagen: placeholder con ícono de la categoría
- Frase de ejemplo en cursiva debajo de la imagen

### 7.3 QuizScreen

- Preguntas con imagen: imagen encima del texto de la pregunta (~200×150 px)
- Al completar el quiz exitosamente: SnackBar o Dialog "¡Lección [N+1] desbloqueada!" antes de navegar al resultado

### 7.4 DiagnosticExamScreen (nueva)

- Barra de progreso lineal (pregunta 1 de 24)
- Imagen de la palabra (centrada, ~240×180 px)
- Pregunta en texto
- 4 botones de opción (A, B, C, D)
- No se muestra retroalimentación inmediata (se muestra al final)
- Botón "Cancelar diagnóstico" en AppBar (con confirmación)

### 7.5 DiagnosticResultScreen (nueva)

- Título: "Tu nivel en Ngigua"
- Subtítulo: "Conoces [X] de 12 temas"
- Lista de lecciones con íconos: ✓ aprobada / 🔒 por aprender
- Botón "Comenzar" → regresa a HomeScreen

---

## 8. Archivos afectados

| Archivo | Tipo de cambio |
|---------|---------------|
| `lib/core/database/database_helper.dart` | Migración v1→v2, bump a version=2 |
| `lib/core/database/database_seeder.dart` | +7 lecciones, +≥55 palabras, +≥70 preguntas, `order_index` en todas las lecciones |
| `lib/core/models/lesson.dart` | +3 campos: orderIndex, isLocked, isCompleted |
| `lib/core/repositories/lesson_repository.dart` | +4 métodos: markCompleted, unlockNext, unlockLessons, getLessonsOrdered |
| `lib/providers/lesson_provider.dart` | Actualizar para usar getLessonsOrdered, agregar completeLesson() |
| `lib/screens/home_screen.dart` | UI lock/unlock, botón diagnóstico |
| `lib/screens/lessons/lesson_list_screen.dart` | Mostrar estado de cada lección |
| `lib/screens/quiz/quiz_result_screen.dart` | Trigger de desbloqueo al completar quiz |
| `lib/screens/quiz/quiz_screen.dart` | Mostrar imágenes en preguntas |
| `lib/screens/diagnostic/diagnostic_exam_screen.dart` | **NUEVO** |
| `lib/screens/diagnostic/diagnostic_result_screen.dart` | **NUEVO** |
| `assets/images/` | ~55 imágenes nuevas (lecciones 6–12) |
| `pubspec.yaml` | Declarar nuevas imágenes en assets |

---

## 9. Orden de implementación recomendado

1. **Migración DB** — `database_helper.dart` versión 2 + campos en modelo `Lesson`
2. **Repositorio** — métodos nuevos en `LessonRepository`
3. **Seeder** — ampliar lecciones 1–5 a ≥10 preguntas + agregar lecciones 6–12 con vocabulario Ngigua
4. **Descargar imágenes** — script Python para lecciones 6–12
5. **UI lock/unlock** — cambios en HomeScreen y LessonListScreen
6. **Quiz trigger** — desbloqueo al completar quiz en QuizResultScreen
7. **DiagnosticExamScreen** — pantalla nueva
8. **DiagnosticResultScreen** — pantalla nueva
9. **Integración final** — conectar todo, pruebas en emulador

---

## 10. Consideraciones culturales

- Todo el vocabulario Ngigua proviene de: *"Vocabulario Diccionario Ngiigua"* — Sharon Stark Campbell, Jacob Luna Hernández, Verónica Luna Villanueva. UNTI A.C., 2016.
- Las frases de ejemplo deben reflejar contexto cultural de San Marcos Tlacoyalco (milpa, fogón, tejido, etc.)
- El contenido debe ser validado por hablantes nativos antes de la presentación oficial en ExpoCiencias.
- Las imágenes deben ser culturalmente neutras o representativas de la región (preferir objetos y animales locales).

---

*Spec generada el 2026-05-22 para TayuNikan — ExpoCiencias 2026*
