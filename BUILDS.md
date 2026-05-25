# TayuNikan — Guía de compilación

## Versión actual: 1.0.0 (build 1)

---

## Android (Windows / Mac / Linux)

```bash
# APK para distribución directa
flutter build apk --release

# Ruta del APK generado:
# build/app/outputs/flutter-apk/app-release.apk

# App Bundle para Google Play Store
flutter build appbundle --release
# build/app/outputs/bundle/release/app-release.aab
```

### Requisitos Android
- Flutter 3.44+
- Android SDK con compileSdk 36
- Java 17

---

## iOS (requiere Mac con Xcode)

### Primera vez (configurar CocoaPods)
```bash
# En la Mac, desde la raíz del proyecto:
flutter pub get
cd ios
pod install
cd ..
```

### Compilar
```bash
# Build para dispositivo físico (sin firma de distribución)
flutter build ios --no-codesign

# Build para App Store (requiere Apple Developer Account)
flutter build ipa
# build/ios/ipa/TayuNikan.ipa
```

### Requisitos iOS
- macOS con Xcode 15+
- CocoaPods instalado (`gem install cocoapods`)
- Apple Developer Account (solo para App Store)
- iOS deployment target: **14.0** (cubre ~97% de dispositivos activos)

### Permisos configurados en Info.plist
| Permiso | Uso |
|---------|-----|
| `NSMicrophoneUsageDescription` | Grabación de pronunciación |
| `NSSpeechRecognitionUsageDescription` | Evaluación de pronunciación (speech_to_text) |
| `NSDocumentsFolderUsageDescription` | Guardado de grabaciones |

---

## Plugins y compatibilidad

| Plugin | Android | iOS |
|--------|---------|-----|
| sqflite | ✅ | ✅ |
| just_audio | ✅ | ✅ iOS 12+ |
| record | ✅ | ✅ iOS 12+ |
| speech_to_text | ✅ | ✅ iOS 13+ |
| file_picker | ✅ | ✅ |
| shared_preferences | ✅ | ✅ |
| path_provider | ✅ | ✅ |
| provider | ✅ | ✅ (Dart puro) |
| crypto | ✅ | ✅ (Dart puro) |

---

## Notas de versioning

El número de versión en `pubspec.yaml` (`version: 1.0.0+1`) aplica para ambas plataformas:
- **Android**: `versionName=1.0.0`, `versionCode=1`
- **iOS**: `CFBundleShortVersionString=1.0.0`, `CFBundleVersion=1`

Al subir una nueva versión, incrementa el build number:
```yaml
version: 1.0.1+2   # nuevo feature
version: 1.1.0+3   # release mayor
```
