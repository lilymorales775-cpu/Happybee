import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../bd/firebase_service.dart';
import '../validadores.dart';
import 'home_apoderado.dart';
import 'home_dentista.dart';
import 'home_nino.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) return;
    final mensajero = ScaffoldMessenger.of(context);
    void mensaje(String texto) =>
        mensajero.showSnackBar(SnackBar(content: Text(texto)));

    setState(() => _cargando = true);
    try {
      final rol =
          await FirebaseService.iniciarSesion(_correo.text, _contrasena.text);
      if (!mounted) return;
      if (rol == null) {
        mensaje('Perfil no encontrado');
        return;
      }
      final Widget destino = rol == 'apoderado'
          ? const HomeApoderadoPage()
          : rol == 'nino'
              ? const HomeNinoPage()
              : const HomeDentistaPage();
      Navigator.push(context, MaterialPageRoute(builder: (_) => destino));
    } on FirebaseAuthException {
      mensaje('Correo o contraseña incorrectos');
    } catch (_) {
      mensaje('No se pudo iniciar sesión');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _correo,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    const InputDecoration(labelText: 'Correo electrónico'),
                validator: validarCorreo,
              ),
              TextFormField(
                controller: _contrasena,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: validarObligatorio,
              ),
              ElevatedButton(
                onPressed: _cargando ? null : _ingresar,
                child: const Text('Ingresar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}