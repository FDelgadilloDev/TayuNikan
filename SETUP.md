# TayuNikan — Guía de configuración y ejecución

## ¿Qué es esto?
Aplicación Android educativa para aprender y preservar lenguas indígenas.
Proyecto ExpoCiencias — Categoría: Sociales y Humanidades.

---

## Paso 1: Instalar Flutter

1. Descarga Flutter SDK: https://flutter.dev/docs/get-started/install/windows
2. Descomprime en `C:\src\flutter` (o donde prefieras)
3. Agrega `C:\src\flutter\bin` a tu variable de entorno `PATH`
4. Verifica: abre una terminal nueva y ejecuta:
   ```
   flutter doctor
   ```
5. Instala Android Studio: https://developer.android.com/studio
6. Acepta licencias de Android SDK:
   ```
   flutter doctor --android-licenses
   ```

---

## Paso 2: Crear el proyecto Flutter base

Abre una terminal **en esta carpeta** y ejecuta:

```powershell
# Crear el proyecto Flutter (genera los archivos base de Android/iOS)
flutter create . --project-name tayunikan --org com.tayunikanpp --platforms android

# Instalar dependencias
flutter pub get
```

> **Nota:** `flutter create .` genera los archivos base de Android. 
> Tu código fuente en `lib/` se preserva automáticamente.

---

## Paso 3: Reemplazar el AndroidManifest.xml

El archivo `android/app/src/main/AndroidManifest.xml` ya está listo con 
todos los permisos necesarios (micrófono, almacenamiento, AdMob).

Si `flutter create` lo sobreescribió, restaura el contenido del archivo 
`android/app/src/main/AndroidManifest.xml` que está en este repositorio.

---

## Paso 4: Ejecutar la app

Conecta un dispositivo Android con depuración USB activada, o usa el
emulador de Android Studio.

```powershell
# Ver dispositivos disponibles
flutter devices

# Ejecutar en dispositivo/emulador
flutter run

# Ejecutar en modo release (más rápido)
flutter run --release
```

---

## Estructura del proyecto

```
lib/
├── main.dart                  → Punto de entrada
├── app.dart                   → MaterialApp, tema, rutas
├── core/
│   ├── constants/             → Colores, tema, rutas
│   ├── database/              → SQLite helper + seeder de datos
│   ├── models/                → Lesson, Word, QuizQuestion, etc.
│   ├── repositories/          → CRUD para cada modelo
│   └── services/              → Audio, grabación, voz, configuración
├── providers/                 → Estado (AuthProvider, LessonProvider, ProgressProvider)
├── screens/
│   ├── welcome_screen.dart
│   ├── home_screen.dart
│   ├── lessons/               → Lista, detalle, palabra
│   ├── quiz/                  → Cuestionario y resultado
│   ├── activities/            → Actividades interactivas
│   ├── progress/              → Avance del estudiante
│   ├── cultural/              → Sección cultural
│   ├── admin/                 → Login admin, panel, crear lección, agregar palabra
│   └── settings/              → Configuración y premium
└── widgets/                   → Componentes reutilizables
```

---

## Cómo usar la app

### Como estudiante:
1. Abre la app → pantalla de bienvenida → "Comenzar"
2. Explora las lecciones de ejemplo
3. Toca una lección → ve las palabras → escucha la pronunciación
4. Graba tu pronunciación y recibe retroalimentación
5. Completa el cuestionario al final de cada lección
6. Revisa tu avance en "Mi Avance"

### Como administrador:
1. Ve a "Configuración" → "Modo Administrador"
2. **Primera vez:** establece un PIN de 4-6 dígitos
3. **Siguientes veces:** ingresa tu PIN
4. Aparecerá un botón flotante para el "Panel de Administración"
5. Desde ahí puedes crear lecciones y agregar palabras

---

## Agregar contenido real

El contenido de ejemplo usa **placeholders** `[ENTRE_CORCHETES]`.
Para agregar contenido real:
1. Activa el modo administrador
2. Crea una nueva lección con el nombre y descripción correctos
3. Agrega palabras con:
   - La palabra en la lengua indígena (texto)
   - Traducción al español
   - Audio de pronunciación (archivo .mp3 o .m4a del hablante nativo)
   - Imagen opcional

**⚠ Recuerda:** Todo el contenido debe ser validado por hablantes nativos
o representantes de la comunidad antes de presentarlo como material oficial.

---

## Dependencias principales

| Paquete | Para qué sirve |
|---------|---------------|
| sqflite | Base de datos SQLite local |
| just_audio | Reproducir audio de pronunciaciones |
| record | Grabar voz del estudiante |
| speech_to_text | Reconocimiento de voz (opcional) |
| provider | Manejo de estado |
| shared_preferences | Configuración persistente (premium, PIN) |
| file_picker | Seleccionar audio/imagen desde el teléfono |
| google_mobile_ads | Publicidad AdMob (no invasiva) |
| crypto | Hash seguro del PIN de admin |

---

## Para la presentación en ExpoCiencias

### Demo rápida (2-3 minutos):
1. Mostrar la pantalla de bienvenida
2. Navegar a la primera lección ("Saludos básicos")
3. Tocar una palabra → escuchar audio (si hay grabación)
4. Demostrar la grabación de voz y la retroalimentación
5. Hacer el cuestionario de la lección
6. Mostrar la pantalla de "Mi Avance"
7. Demostrar el modo administrador creando una nueva lección

### Puntos clave a mencionar:
- Funciona 100% sin internet
- El admin puede agregar contenido nuevo directamente desde el teléfono
- El sistema de pronunciación es honesto: admite que puede no reconocer todas las lenguas
- El contenido debe ser validado por hablantes nativos (demuestra responsabilidad cultural)

---

## ¿Problemas comunes?

**"No se puede grabar audio"** → Activa el permiso de micrófono en Configuración del teléfono

**"No reconoce mi pronunciación"** → Es normal para lenguas indígenas; usa el botón 
"Guardar para revisión" y muéstrasela a tu docente o hablante nativo

**"La app es lenta"** → Usa `flutter run --release` para mejor rendimiento

---

*TayuNikan — Proyecto ExpoCiencias 2026*
*Área: Sociales y Humanidades*
*Nota: Contenido validado por [NOMBRE_DE_LA_COMUNIDAD]*
