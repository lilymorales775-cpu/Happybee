import 'package:flutter/material.dart';
import 'cepillado.dart';
import 'perfil.dart';
import 'historial.dart';

class HomeNinoPage extends StatelessWidget {
  const HomeNinoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Niño')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Actividades'),
            // Hito 4: inicia la guía de cepillado de 2 minutos.
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CepilladoPage())),
              child: const Text('Cepillarse los dientes'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PerfilPage())),
              child: const Text('Perfil'),
            ),
            // Hito 5: ver historial de sesiones de cepillado.
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HistorialPage())),
              child: const Text('Historial'),
            ),
          ],
        ),
      ),
    );
  }
}
