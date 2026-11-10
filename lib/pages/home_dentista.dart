import 'package:flutter/material.dart';
import 'historialdentist.dart';
import 'perfil.dart';

class HomeDentistaPage extends StatelessWidget {
  const HomeDentistaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Dentista')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pacientes'),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistorialDentistPage()),
              ),
              icon: const Icon(Icons.history),
              label: const Text('Historial de pacientes'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerfilPage()),
              ),
              child: const Text('Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
