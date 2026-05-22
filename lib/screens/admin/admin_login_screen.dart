import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';

/// Pantalla de login del administrador con PIN de 4-6 dígitos.
/// La primera vez que se ingresa, el PIN se establece automáticamente.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _isFirstTime = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final hasPin = await context.read<AuthProvider>().hasAdminPin();
    if (mounted) setState(() => _isFirstTime = !hasPin);
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final pin = _pinController.text.trim();
    if (pin.length < 4) {
      setState(() => _error = 'El PIN debe tener al menos 4 dígitos.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final success = await auth.loginAdmin(pin);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.adminPanel);
    } else {
      setState(() => _error = 'PIN incorrecto. Intenta de nuevo.');
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Administrador'),
        backgroundColor: AppColors.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.admin_panel_settings_rounded,
              size: 80,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 24),
            Text(
              _isFirstTime
                  ? 'Configura tu PIN de administrador'
                  : 'Ingresa tu PIN de administrador',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _isFirstTime
                  ? 'Este PIN protegerá el acceso de administración.\nGuárdalo en un lugar seguro.'
                  : 'Solo el administrador puede crear y editar lecciones.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '• • • •',
                counterText: '',
                errorText: _error,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_isFirstTime ? 'Establecer PIN' : 'Entrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
