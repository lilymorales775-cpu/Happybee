import 'package:flutter/material.dart';
import 'registro.dart';

class TipoUsuarioPage extends StatelessWidget {
  const TipoUsuarioPage({super.key});

  Widget _boton(BuildContext context, String etiqueta, String rol) {
    return ElevatedButton(
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => RegistroPage(rol: rol))),
      child: Text(etiqueta),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tipo de usuario')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Quién eres?'),
            _boton(context, 'Apoderado', 'apoderado'),
            _boton(context, 'Niño/Alumno', 'nino'),
            _boton(context, 'Dentista', 'dentista'),
          ],
        ),
      ),
    );
  }
}