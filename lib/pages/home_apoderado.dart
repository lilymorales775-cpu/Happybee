import 'package:flutter/material.dart';
import '../bd/firebase_service.dart';
import 'perfil.dart';

class HomeApoderadoPage extends StatefulWidget {
  const HomeApoderadoPage({super.key});

  @override
  State<HomeApoderadoPage> createState() => _HomeApoderadoPageState();
}

class _HomeApoderadoPageState extends State<HomeApoderadoPage> {
  late final Future<List<Map<String, dynamic>>> _hijos =
      FirebaseService.listarHijos();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Apoderado')),
      body: Column(
        children: [
          const Text('Mis hijos'),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _hijos,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('No se pudieron cargar los hijos'));
                }
                final hijos = snapshot.data!;
                if (hijos.isEmpty) {
                  return const Center(child: Text('Sin hijos registrados'));
                }
                return ListView(
                  children: [
                    for (final h in hijos)
                      ListTile(title: Text('${h['nombre']} ${h['apellido']}')),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PerfilPage())),
            child: const Text('Perfil'),
          ),
        ],
      ),
    );
  }
}