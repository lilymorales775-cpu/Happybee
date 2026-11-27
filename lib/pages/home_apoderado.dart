import 'package:flutter/material.dart';
import '../bd/firebase_service.dart';
import '../validadores.dart';
import 'perfil.dart';
import 'historial.dart';

class HomeApoderadoPage extends StatefulWidget {
  const HomeApoderadoPage({super.key});

  @override
  State<HomeApoderadoPage> createState() => _HomeApoderadoPageState();
}

class _HomeApoderadoPageState extends State<HomeApoderadoPage> {
  List<Map<String, dynamic>> _ninos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // Hito 3: lista solo los niños del apoderado autenticado (apoderadoUid).
  Future<void> _cargar() async {
    final lista = await FirebaseService.listarNinos();
    if (!mounted) return;
    setState(() {
      _ninos = lista;
      _cargando = false;
    });
  }

  // Abre el formulario para crear (nino == null) o editar un niño existente.
  Future<void> _abrirFormulario({Map<String, dynamic>? nino}) async {
    final nombreCtrl = TextEditingController(text: nino?['nombre'] ?? '');
    final edadCtrl =
        TextEditingController(text: nino?['edad']?.toString() ?? '');
    final avatarCtrl = TextEditingController(text: nino?['avatar'] ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(nino == null ? 'Agregar niño' : 'Editar niño'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => validarObligatorio(v),
              ),
              TextFormField(
                controller: edadCtrl,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                validator: (v) => validarEdad(v),
              ),
              TextFormField(
                controller: avatarCtrl,
                decoration: const InputDecoration(labelText: 'Avatar'),
                validator: (v) => validarObligatorio(v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                if (nino == null) {
                  await FirebaseService.crearNino(
                    nombre: nombreCtrl.text,
                    edad: int.parse(edadCtrl.text),
                    avatar: avatarCtrl.text,
                  );
                } else {
                  await FirebaseService.actualizarNino(
                    id: nino['id'],
                    nombre: nombreCtrl.text,
                    edad: int.parse(edadCtrl.text),
                    avatar: avatarCtrl.text,
                  );
                }
                if (!mounted) return;
                Navigator.pop(context);
                // Diferir la recarga para evitar error de framework al cerrar el diálogo.
                Future.delayed(Duration.zero, () {
                  if (mounted) _cargar();
                });
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: Text(nino == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );
    nombreCtrl.dispose();
    edadCtrl.dispose();
    avatarCtrl.dispose();
  }

  // Hito 3: elimina un niño tras confirmar.
  Future<void> _eliminar(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar niño'),
        content: const Text('¿Eliminar este niño?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await FirebaseService.eliminarNino(id);
      // Diferir la recarga para evitar error de framework al cerrar el diálogo.
      Future.delayed(Duration.zero, () {
        if (mounted) _cargar();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Apoderado')),
      body: Column(
        children: [
          const Text('Mis hijos'),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _ninos.isEmpty
                    ? const Center(child: Text('Sin hijos registrados'))
                    : ListView(
                        children: [
                          for (final n in _ninos)
                            ListTile(
                              title: Text('${n['nombre']} (${n['edad']})'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _abrirFormulario(nino: n),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _eliminar(n['id']),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
          ),
          ElevatedButton(
            onPressed: () => _abrirFormulario(),
            child: const Text('Agregar niño'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PerfilPage())),
            child: const Text('Perfil'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HistorialPage())),
            child: const Text('Historial'),
          ),
        ],
      ),
    );
  }
}
