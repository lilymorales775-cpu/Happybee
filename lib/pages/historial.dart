import 'package:flutter/material.dart';
import '../bd/firebase_service.dart';

// Hito 5: historial de sesiones de cepillado del usuario autenticado.
class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  List<Map<String, dynamic>> _sesiones = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // Hito 5: consulta solo las sesiones del usuario autenticado (apoderadoUid).
  Future<void> _cargar() async {
    final lista = await FirebaseService.listarSesiones();
    if (!mounted) return;
    setState(() {
      _sesiones = lista;
      _cargando = false;
    });
  }

  String _fechaLegible(dynamic fecha) {
    if (fecha == null) return '-';
    try {
      final f = fecha.toDate();
      return '${f.day}/${f.month}/${f.year} ${f.hour}:${f.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return fecha.toString();
    }
  }

  String _idCorto(dynamic id) {
    if (id == null) return '-';
    final s = id.toString();
    return s.length > 8 ? '${s.substring(0, 8)}...' : s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: Column(
        children: [
          const Text('Sesiones de cepillado'),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _sesiones.isEmpty
                    ? const Center(child: Text('Sin sesiones registradas'))
                    : ListView(
                        children: [
                          for (final s in _sesiones)
                            ListTile(
                              title: Text('Niño: ${_idCorto(s['ninoId'])}'),
                              subtitle: Text(
                                  'Duración: ${s['duracionSegundos'] ?? '-'} s'),
                              trailing: Text(_fechaLegible(s['fecha'])),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
