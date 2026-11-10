import 'package:flutter/material.dart';
import '../bd/firebase_service.dart';

class CerrarSesionPage extends StatelessWidget {
  const CerrarSesionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cerrar sesión')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Cerrar la sesión activa?'),
            ElevatedButton(
              onPressed: () async {
                await FirebaseService.cerrarSesion();
                if (!context.mounted) return;
                Navigator.popUntil(context, (ruta) => ruta.isFirst);
              },
              child: const Text('Cerrar sesión'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}