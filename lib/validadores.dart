String? validarObligatorio(String? valor) {
  if (valor == null || valor.trim().isEmpty) return 'Campo obligatorio';
  return null;
}

String? validarCorreo(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) return 'Campo obligatorio';
  final arroba = texto.indexOf('@');
  if (arroba < 1) return 'Correo inválido';
  final punto = texto.indexOf('.', arroba);
  if (punto < arroba + 2 || punto == texto.length - 1) return 'Correo inválido';
  return null;
}

String? validarContrasena(String? valor) {
  if (valor == null || valor.isEmpty) return 'Campo obligatorio';
  if (valor.length < 6) return 'Mínimo 6 caracteres';
  return null;
}

String? validarConfirmacion(String? valor, String contrasena) {
  if (valor == null || valor.isEmpty) return 'Campo obligatorio';
  if (valor != contrasena) return 'Las contraseñas no coinciden';
  return null;
}

int calcularEdad(DateTime nacimiento) {
  final hoy = DateTime.now();
  int edad = hoy.year - nacimiento.year;
  final aunNoCumple = hoy.month < nacimiento.month ||
      (hoy.month == nacimiento.month && hoy.day < nacimiento.day);
  if (aunNoCumple) edad--;
  return edad;
}

String? validarEdad(String? valor) {
  final edad = int.tryParse(valor ?? '');
  if (edad == null) return 'Elige la fecha de nacimiento';
  if (edad < 7 || edad > 12) return 'La edad debe estar entre 7 y 12 años';
  return null;
}

String? validarRut(String? valor) {
  final rut = (valor ?? '').replaceAll(RegExp(r'[.\-\s]'), '').toUpperCase();
  if (rut.isEmpty) return 'Campo obligatorio';
  if (!RegExp(r'^\d{7,8}[\dK]$').hasMatch(rut)) return 'RUT inválido';

  final cuerpo = rut.substring(0, rut.length - 1);
  var suma = 0;
  var multiplicador = 2;
  for (var indice = cuerpo.length - 1; indice >= 0; indice--) {
    suma += int.parse(cuerpo[indice]) * multiplicador;
    multiplicador = multiplicador == 7 ? 2 : multiplicador + 1;
  }

  final resto = 11 - suma % 11;
  final digitoEsperado = switch (resto) {
    11 => '0',
    10 => 'K',
    _ => resto.toString(),
  };
  if (rut[rut.length - 1] != digitoEsperado) return 'RUT inválido';
  return null;
}