import 'package:flutter/material.dart';
import 'perfil.dart';

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
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PerfilPage())),
              child: const Text('Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}