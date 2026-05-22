import 'package:flutter/foundation.dart';
import '../core/services/settings_service.dart';

/// Maneja el estado de autenticación: modo admin y estado premium.
class AuthProvider extends ChangeNotifier {
  final SettingsService _settings = SettingsService();

  bool _isAdminMode = false;
  bool _isPremium = false;

  bool get isAdminMode => _isAdminMode;
  bool get isPremium => _isPremium;

  /// Carga el estado inicial (premium) desde almacenamiento.
  Future<void> initialize() async {
    _isPremium = await _settings.isPremium;
    notifyListeners();
  }

  /// Intenta activar el modo admin con el PIN proporcionado.
  ///
  /// Si no hay PIN configurado aún (primera vez), establece el PIN y activa el modo.
  /// Devuelve true si el acceso fue concedido.
  Future<bool> loginAdmin(String pin) async {
    if (pin.length < 4) return false;

    final hasPin = await _settings.hasAdminPin();
    if (!hasPin) {
      // Primera vez: el PIN se convierte en el PIN del admin
      await _settings.setAdminPin(pin);
      _isAdminMode = true;
      notifyListeners();
      return true;
    }

    final valid = await _settings.validateAdminPin(pin);
    if (valid) {
      _isAdminMode = true;
      notifyListeners();
    }
    return valid;
  }

  /// Cierra el modo admin (regresa al modo estudiante).
  void logoutAdmin() {
    _isAdminMode = false;
    notifyListeners();
  }

  /// Activa el modo premium (sin publicidad).
  Future<void> activatePremium() async {
    await _settings.setPremium(true);
    _isPremium = true;
    notifyListeners();
  }

  Future<bool> hasAdminPin() => _settings.hasAdminPin();
}
