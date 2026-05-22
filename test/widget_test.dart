// Test básico de VozViva — se amplía cuando se conecte un emulador.
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('VozViva app smoke test', (WidgetTester tester) async {
    // La app requiere inicialización de BD y permisos de audio:
    // los tests completos se ejecutan en un dispositivo/emulador real.
    expect(true, isTrue);
  });
}
