import 'package:flutter/material.dart';
import '../bd/firebase_service.dart';
import '../validadores.dart';

class HistorialDentistPage extends StatefulWidget {
  const HistorialDentistPage({super.key});

  @override
  State<HistorialDentistPage> createState() => _HistorialDentistPageState();
}

class _HistorialDentistPageState extends State<HistorialDentistPage> {
  late Future<List<Map<String, dynamic>>> _pacientes;

  @override
  void initState() {
    super.initState();
    _cargarPacientes();
  }

  void _cargarPacientes() {
    _pacientes = FirebaseService.listarPacientesNinos();
  }

  void _reintentar() {
    setState(_cargarPacientes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de pacientes')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pacientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudieron cargar los pacientes'),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _reintentar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final pacientes = snapshot.data ?? [];
          if (pacientes.isEmpty) {
            return const Center(
              child: Text('No hay pacientes niños registrados'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: pacientes.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final paciente = pacientes[index];
              final nombre =
                  '${paciente['nombre'] ?? ''} ${paciente['apellido'] ?? ''}'
                      .trim();
              final nacimiento = paciente['fechaNacimiento'];
              final edad = nacimiento is DateTime
                  ? calcularEdad(nacimiento)
                  : null;
              final sexo = paciente['sexo'] as String?;
              final detalles = [
                if (edad != null && edad >= 0) '$edad años',
                if (sexo != null && sexo.isNotEmpty) sexo,
              ];

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.child_care)),
                title: Text(nombre.isEmpty ? 'Paciente sin nombre' : nombre),
                subtitle: detalles.isEmpty ? null : Text(detalles.join(' · ')),
              );
            },
          );
        },
      ),
    );
  }
}
