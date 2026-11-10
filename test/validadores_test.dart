import 'package:flutter_test/flutter_test.dart';
import 'package:happybee/validadores.dart';

void main() {
  group('validarRut', () {
    test('acepta RUT con formato y dígito numérico válido', () {
      expect(validarRut('12.345.678-5'), isNull);
    });

    test('acepta K minúscula como dígito verificador', () {
      expect(validarRut('6000000-k'), isNull);
    });

    test('rechaza un dígito verificador incorrecto', () {
      expect(validarRut('12.345.678-9'), 'RUT inválido');
    });

    test('rechaza formatos incompletos', () {
      expect(validarRut('123456'), 'RUT inválido');
    });

    test('requiere un valor', () {
      expect(validarRut('  '), 'Campo obligatorio');
    });
  });
}