# TayuNikan — Diseño de mejoras v2

**Fecha:** 2026-05-25
**Proyecto:** TayuNikan — App educativa para Ngigua (Popoloca) de San Marcos Tlacoyalco
**Alcance:** 4 mejoras independientes: bug actividades, audio TTS, imágenes mejoradas, 15 preguntas por lección

---

## 1. Tarea 1 — Fix bug actividades

### Problema
En `_MultipleChoiceActivity._next()`, al terminar la última pregunta se ejecuta:
```dart
Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(...); // ← context inválido
```
`context` ya está destruido cuando se llama al SnackBar, causando un error que bloquea la navegación.

### Solución
Guardar la referencia al `ScaffoldMessenger` **antes** de hacer `pop`:
```dart
final messenger = ScaffoldMessenger.of(context);
Navigator.pop(context);
messenger.showSnackBar(...);
```

### Mejora adicional — botón "Jugar de nuevo"
Las 3 actividades (`_MatchActivity`, `_MultipleChoiceActivity`, `_FlashcardActivity`) solo muestran "Volver" al terminar. Se agrega un botón "Jugar de nuevo" que reinicia la actividad con nuevas palabras aleatorias sin salir de la pantalla.

- `_MatchActivity`: reinicia `_subset`, `_matches`, `_score`, `_done = false`
- `_MultipleChoiceActivity`: reinicia `_index`, `_score`, `_answered`, re-mezcla palabras
- `_FlashcardActivity`: reinicia `_index`, `_showTranslation`, re-mezcla tarjetas

**Archivo afectado:** `lib/screens/activities/activities_screen.dart`

---

## 2. Tarea 2 — Audio con voz de mujer (gTTS)

### Objetivo
Generar archivos `.mp3` de pronunciación para las ~84 palabras del seeder usando Google TTS (gTTS) con voz española femenina.

### Nomenclatura de archivos
```
assets/audio/[categoria]_[orden].mp3
```
Ejemplo: `assets/audio/saludo_1.mp3` = "deo", `assets/audio/saludo_2.mp3` = "jian", etc.

### Script de generación
`scripts/generate_audio.py` — usa `gtts` (pip install gTTS):
- Lee la lista de palabras por categoría desde el seeder
- Genera MP3 con `gTTS(text=palabra, lang='es', slow=True)` para que se escuche más claramente
- Velocidad lenta (`slow=True`) mejora la comprensión de palabras poco familiares

### Pronunciación Ngigua → español
El TTS español pronunciará las palabras Ngigua según su ortografía. Aproximaciones útiles:
- `j` en Ngigua suena /h/ en español (como en "jarro") — el TTS lo pronuncia bien
- `th` suena africado — el TTS lo leerá como /t/ + /e/ que es aceptable
- `x` suena /sh/ — el TTS lo leerá como /ks/, que es una aproximación
- Palabras compuestas con espacio (`jian nchaon`) se leen como frase

### Actualización del seeder
Cada palabra en `database_seeder.dart` recibe su `audio_path` correspondiente:
```dart
('deo', 'Saludo al encontrar a alguien', 'assets/images/saludo_deo.jpg',
 'Deo — ...', 'assets/audio/saludo_1.mp3'),
```

### pubspec.yaml
Agregar:
```yaml
assets:
  - assets/audio/
```

**Archivos afectados:**
- `scripts/generate_audio.py` (nuevo)
- `lib/core/database/database_seeder.dart` (audio_path en cada palabra)
- `pubspec.yaml` (declarar assets/audio/)

---

## 3. Tarea 3 — Imágenes MET mejoradas

### Problema
Los términos de búsqueda anteriores devolvían obras de arte abstractas del MET. Solo los animales tienen imágenes claras porque sus nombres en inglés son directos.

### Estrategia
Usar términos de búsqueda **más específicos y visuales**, y eliminar el filtro `medium=Watercolors` para tener más candidatos. Se priorizan ilustraciones naturalistas y educativas sobre arte abstracto.

### Términos de búsqueda mejorados por categoría

| Imagen | Término nuevo |
|--------|--------------|
| cuerpo_jaa (cabeza) | `head study figure` |
| cuerpo_jmakon (ojo) | `eye study botanical` |
| cuerpo_chinthjon (nariz) | `nose anatomy figure` |
| cuerpo_rua (boca) | `mouth lips study` |
| cuerpo_raa (mano) | `hand study fingers` |
| cuerpo_ruthea (pie) | `foot study anatomy` |
| cuerpo_neje (lengua) | `tongue mouth anatomy` |
| cuerpo_thusin (cuello) | `neck figure portrait` |
| alimento_nio (tortilla) | `flat bread cooking` |
| alimento_nua (maíz) | `corn maize plant botanical` |
| alimento_niunthaon (tamal) | `food wrapped corn husk` |
| alimento_thukma (papa) | `potato tuber botanical` |
| alimento_thuchmoin (fruta) | `fruit still life` |
| alimento_ndaxra (comida) | `meal bowl food serving` |
| alimento_tumi (dinero) | `coin currency` |
| verbo_nichma (hablar) | `conversation figure talking` |
| verbo_thji (ir) | `figure walking path` |
| verbo_thii (venir) | `figure arrival welcome` |
| verbo_tsjee (mirar) | `figure observation gazing` |
| verbo_thjen (lavar) | `washing water hands` |
| verbo_tsmjan (reír) | `laughing smile happy` |
| verbo_tsmjang (llorar) | `crying tears sadness` |
| verbo_ruchrin (brincar) | `figure jumping leaping` |
| casa_nchian (casa) | `house cottage rural` |
| casa_nuxra (cobija) | `blanket textile woven` |
| casa_xrui (fuego) | `fire flame torch` |
| casa_nthaa (árbol/madera) | `tree trunk wood` |
| casa_xro (piedra) | `stone rocks pebble` |
| casa_xroon (papel) | `paper manuscript writing` |
| casa_nunthe (tierra) | `soil earth ground` |
| casa_xra (trabajo) | `labor craft artisan` |
| ropa_ruthe (rebozo) | `woman shawl wrap` |
| ropa_xranchritmja (sombrero) | `wide brim hat straw` |
| ropa_ruthe_jatse (rebozo rojo) | `red textile fabric` |
| ropa_ruthe_thie (rebozo negro) | `black cloth textile` |
| ropa_nuxra_rua (tela blanca) | `white linen fabric` |
| ropa_raa_ruthe (faja) | `belt sash textile band` |
| ropa_ruthea_nuxra (sandalia) | `sandal shoe leather` |
| tiempo_nchaon (sol) | `sun rays landscape` |
| tiempo_chrin (lluvia) | `rain drops storm` |
| tiempo_nunthe (tierra) | `earth soil field` |
| tiempo_nthaa (monte) | `mountain forest trees` |
| tiempo_xro (piedra) | `stone rock boulders` |
| tiempo_rajna (pueblo) | `village settlement houses` |
| tiempo_nua (milpa) | `corn field agriculture` |
| tiempo_xrui (fuego/calor) | `fire warmth campfire` |
| frase_deo (hola) | `greeting handshake meeting` |
| frase_jian (bien) | `happiness joy figure` |
| frase_thji (vamos) | `walking group journey` |
| frase_nthii (aquí) | `here place location` |
| frase_nthia (allá) | `distance horizon far` |
| frase_jian_nchaon (buenos días) | `morning sunrise dawn` |
| frase_nichma_ngigua (habla Ngigua) | `indigenous language book` |

**Archivos afectados:** `scripts/download_images.py` (nuevos términos + re-descarga)

---

## 4. Tarea 4 — 15 preguntas por lección

### Objetivo
Agregar 5 preguntas adicionales por lección en `database_seeder.dart`, elevando de 10 a 15 el total por lección.

### Tipos de preguntas nuevas
Las 5 preguntas adicionales usarán variaciones que refuercen de forma diferente:
- Imagen → palabra Ngigua (descripción del concepto como pregunta)
- Frase incompleta en Ngigua (completar con la palabra correcta)
- ¿Cuál NO pertenece al grupo? (odd-one-out temático)
- Traducción inversa más directa (español → Ngigua)
- Pregunta de contexto cultural (uso en la comunidad de San Marcos)

**Total:** 15 preguntas × 12 lecciones = 180 preguntas

**Archivo afectado:** `lib/core/database/database_seeder.dart`

---

## 5. Orden de implementación

1. Fix bug actividades (`activities_screen.dart`) — 10 min
2. Generar audio (`scripts/generate_audio.py`) — correr script
3. Actualizar seeder con audio_path + pubspec.yaml
4. Re-descargar imágenes mejoradas (`scripts/download_images.py`)
5. Agregar 5 preguntas por lección al seeder
6. Build APK final

---

*Spec generada el 2026-05-25 para TayuNikan v2 — ExpoCiencias 2026*
