import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Gestiona configuración persistente simple usando SharedPreferences.
/// Incluye: estado premium, PIN de admin, racha de práctica, primer lanzamiento.
class SettingsService {
  static const String _keyIsPremium = 'is_premium';
  static const String _keyAdminPinHash = 'admin_pin_hash';
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyPracticeStreak = 'practice_streak';
  static const String _keyLastPracticeDate = 'last_practice_date';

  // ─── Premium ───────────────────────────────────────────────────────────────

  Future<bool> get isPremium async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPremium) ?? false;
  }

  Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, value);
  }

  // ─── Primer lanzamiento ────────────────────────────────────────────────────

  Future<bool> get isFirstLaunch async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstLaunch, false);
  }

  // ─── PIN del administrador ─────────────────────────────────────────────────

  Future<bool> hasAdminPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString(_keyAdminPinHash);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setAdminPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAdminPinHash, _hashPin(pin));
  }

  Future<bool> validateAdminPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_keyAdminPinHash) ?? '';
    return storedHash == _hashPin(pin);
  }

  /// Genera un hash SHA-256 del PIN para no guardarlo en texto plano.
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  // ─── Racha de práctica ─────────────────────────────────────────────────────

  /// Devuelve la racha actual de días consecutivos de práctica.
  Future<int> get practiceStreak async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_keyLastPracticeDate) ?? '';
    final today = _todayString();
    final yesterday = _yesterdayString();

    if (lastDate == today) {
      return prefs.getInt(_keyPracticeStreak) ?? 1;
    } else if (lastDate == yesterday) {
      return prefs.getInt(_keyPracticeStreak) ?? 0;
    } else {
      return 0; // Racha rota
    }
  }

  /// Registra que el usuario practicó hoy.
  /// Si practicó ayer, incrementa la racha; si no, la reinicia a 1.
  Future<void> recordPracticeToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final lastDate = prefs.getString(_keyLastPracticeDate) ?? '';

    if (lastDate == today) return; // Ya registrado hoy

    final yesterday = _yesterdayString();
    final currentStreak = prefs.getInt(_keyPracticeStreak) ?? 0;
    final newStreak = (lastDate == yesterday) ? currentStreak + 1 : 1;

    await prefs.setInt(_keyPracticeStreak, newStreak);
    await prefs.setString(_keyLastPracticeDate, today);
  }

  String _todayString() =>
      DateTime.now().toIso8601String().substring(0, 10);

  String _yesterdayString() =>
      DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .substring(0, 10);
}
