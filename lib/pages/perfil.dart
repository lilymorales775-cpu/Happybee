import 'package:flutter/material.dart';
import '../bd/firebase_service.dart';
import 'cerrar_sesion.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late final Future<Map<String, dynamic>> _perfil =
      FirebaseService.obtenerPerfil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _perfil,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return const Text('No se pudo cargar el perfil');
              }
              final p = snapshot.data!;
              return Column(
                children: [
                  Text('Nombre: ${p['nombre']}'),
                  Text('Apellido: ${p['apellido']}'),
                  Text('Correo: ${p['correo']}'),
                  Text('Rol: ${p['rol']}'),
                ],
              );
            },
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CerrarSesionPage())),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}