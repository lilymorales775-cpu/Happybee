import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../bd/firebase_service.dart';
import '../validadores.dart';

class RegistroPage extends StatefulWidget {
  final String rol;
  const RegistroPage({super.key, required this.rol});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _rut = TextEditingController();
  final _telefono = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  final _confirmacion = TextEditingController();
  final _especialidad = TextEditingController();
  final _numeroRegistro = TextEditingController();
  final _correoApoderado = TextEditingController();
  final _fecha = TextEditingController();
  final _edad = TextEditingController();

  DateTime? _fechaNacimiento;
  String? _sexo;
  bool _cargando = false; 

  static const _titulos = {
    'apoderado': 'Apoderado',
    'nino': 'Niño/Alumno',
    'dentista': 'Dentista',
  };

  bool get _esNino => widget.rol == 'nino';
  bool get _esDentista => widget.rol == 'dentista';

  @override
  void dispose() {
    for (final c in [
      _nombre, _apellido, _rut, _telefono, _correo, _contrasena,
      _confirmacion, _especialidad, _numeroRegistro, _correoApoderado,
      _fecha, _edad,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _campo(String etiqueta, TextEditingController controlador,
      {String? Function(String?)? validador,
      bool oculto = false,
      TextInputType? teclado}) {
    return TextFormField(
      controller: controlador,
      obscureText: oculto,
      keyboardType: teclado,
      decoration: InputDecoration(labelText: etiqueta),
      validator: validador ?? validarObligatorio,
    );
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: DateTime(hoy.year - 10, hoy.month, hoy.day),
      firstDate: DateTime(hoy.year - 20),
      lastDate: hoy,
    );
    if (elegida == null || !mounted) return;
    setState(() {
      _fechaNacimiento = elegida;
      _fecha.text =
          '${elegida.day.toString().padLeft(2, '0')}/${elegida.month.toString().padLeft(2, '0')}/${elegida.year}';
      _edad.text = calcularEdad(elegida).toString();
    });
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final mensajero = ScaffoldMessenger.of(context);
    void mensaje(String texto) =>
        mensajero.showSnackBar(SnackBar(content: Text(texto)));

    setState(() => _cargando = true);
    try {
      if (_esNino) {
        final ok = await FirebaseService.registrarNino(
          correo: _correo.text,
          contrasena: _contrasena.text,
          correoApoderado: _correoApoderado.text,
          datos: {
            'nombre': _nombre.text.trim(),
            'apellido': _apellido.text.trim(),
            'fechaNacimiento': _fechaNacimiento,
            'sexo': _sexo,
          },
        );
        if (!ok) {
          mensaje('Apoderado no encontrado');
          return;
        }
      } else {
        await FirebaseService.registrarUsuario(
          correo: _correo.text,
          contrasena: _contrasena.text,
          datos: <String, dynamic>{
            'nombre': _nombre.text.trim(),
            'apellido': _apellido.text.trim(),
            'rol': widget.rol,
            'rut': _rut.text.trim(),
            'telefono': _telefono.text.trim(),
            if (_esDentista) 'especialidad': _especialidad.text.trim(),
            if (_esDentista) 'numeroRegistro': _numeroRegistro.text.trim(),
          },
        );
      }
      if (!mounted) return;
      Navigator.popUntil(context, (ruta) => ruta.isFirst);
      mensaje('Registro exitoso, inicia sesión');
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth (${e.code}): ${e.message}');
      final texto = switch (e.code) {
        'email-already-in-use' => 'Este correo ya está registrado',
        'weak-password' => 'La contraseña no cumple los requisitos de Firebase',
        'invalid-email' => 'Firebase rechazó el formato del correo',
        'operation-not-allowed' =>
          'El registro con correo y contraseña no está habilitado en Firebase',
        _ => e.message ?? 'No se pudo autenticar el registro',
      };
      mensaje('$texto (${e.code})');
    } on FirebaseException catch (e) {
      debugPrint('Firebase ${e.plugin} (${e.code}): ${e.message}');
      mensaje('Firebase ${e.plugin} (${e.code}): ${e.message ?? "Error sin detalle"}');
    } catch (e) {
      debugPrint('Error inesperado al registrar: $e');
      mensaje('No se pudo completar el registro');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro: ${_titulos[widget.rol]}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _campo('Nombre', _nombre),
              _campo('Apellido', _apellido),
              if (!_esNino) ...[
                _campo('RUT', _rut, validador: validarRut),
                _campo('Teléfono', _telefono, teclado: TextInputType.phone),
              ],
              _campo('Correo electrónico', _correo,
                  validador: validarCorreo, teclado: TextInputType.emailAddress),
              _campo('Contraseña', _contrasena,
                  validador: validarContrasena, oculto: true),
              _campo('Confirmar contraseña', _confirmacion,
                  validador: (v) => validarConfirmacion(v, _contrasena.text),
                  oculto: true),
              if (_esDentista) ...[
                _campo('Especialidad', _especialidad),
                _campo('Número de registro profesional', _numeroRegistro),
              ],
              if (_esNino) ...[
                TextFormField(
                  controller: _fecha,
                  readOnly: true,
                  decoration:
                      const InputDecoration(labelText: 'Fecha de nacimiento'),
                  validator: validarObligatorio,
                  onTap: _elegirFecha,
                ),
                TextFormField(
                  controller: _edad,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Edad (años)'),
                  validator: validarEdad,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Sexo'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Masculino', child: Text('Masculino')),
                    DropdownMenuItem(
                        value: 'Femenino', child: Text('Femenino')),
                  ],
                  onChanged: (valor) => _sexo = valor,
                  validator: (valor) =>
                      valor == null ? 'Campo obligatorio' : null,
                ),
                _campo('Correo del apoderado', _correoApoderado,
                    validador: validarCorreo,
                    teclado: TextInputType.emailAddress),
              ],
              ElevatedButton(
                onPressed: _cargando ? null : _enviar,
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}