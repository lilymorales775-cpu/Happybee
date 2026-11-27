import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../bd/firebase_service.dart';

// Hito 4: pantalla de guía de cepillado de 2 minutos con temporizador,
// captura aleatoria con cámara real y registro de sesión en Firestore + Storage.
class CepilladoPage extends StatefulWidget {
  const CepilladoPage({super.key});

  @override
  State<CepilladoPage> createState() => _CepilladoPageState();
}

class _CepilladoPageState extends State<CepilladoPage> {
  CameraController? _camara;
  List<CameraDescription> _camaras = [];
  int _segundosRestantes = 120; // 2 minutos
  bool _timerActivo = false;
  bool _cargandoCamara = false;
  String? _mensajeError;

  @override
  void initState() {
    super.initState();
    _iniciarCamara();
  }

  // Hito 4: prioriza la cámara frontal y maneja permisos/fallas.
  Future<void> _iniciarCamara() async {
    try {
      _camaras = await availableCameras();
      final camara = _camaras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _camaras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => _camaras.first,
        ),
      );
      _camara = CameraController(camara, ResolutionPreset.low);
      await _camara!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => _mensajeError = 'Cámara no disponible: $e');
    }
  }

  // Hito 4: captura una foto con la cámara real.
  Future<void> _tomarFoto() async {
    if (_camara == null || !_camara!.value.isInitialized) return;
    try {
      await _camara!.takePicture();
      if (!mounted) return;
      setState(() => _mensajeError = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Captura realizada')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _mensajeError = 'No se pudo capturar: $e');
    }
  }

  // Hito 4: inicia o pausa el temporizador de 2 minutos.
  void _toggleTimer() {
    setState(() => _timerActivo = !_timerActivo);
    if (_timerActivo) _correrTimer();
  }

  Future<void> _correrTimer() async {
    while (_timerActivo && _segundosRestantes > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_timerActivo) return;
      setState(() => _segundosRestantes--);
    }
    if (_segundosRestantes == 0 && mounted) {
      setState(() => _timerActivo = false);
      _finalizar();
    }
  }

  // Hito 4: guarda la sesión de cepillado en Firestore (sin imagen, solo datos de la sesión).
  Future<void> _finalizar() async {
    setState(() => _cargandoCamara = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseService.guardarSesionCepillado(
        apoderadoUid: uid,
        ninoId: uid,
        duracionSegundos: 120 - _segundosRestantes,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _mensajeError = 'No se guardó la sesión: $e');
    } finally {
      if (mounted) setState(() => _cargandoCamara = false);
    }
  }

  @override
  void dispose() {
    _camara?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cepillado (2 min)')),
      body: Column(
        children: [
          // Vista previa de la cámara o mensaje de error.
          if (_mensajeError != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_mensajeError!,
                  style: const TextStyle(color: Colors.red)),
            )
          else if (_camara != null && _camara!.value.isInitialized)
            AspectRatio(
              aspectRatio: _camara!.value.aspectRatio,
              child: CameraPreview(_camara!),
            )
          else
            const SizedBox(
              height: 200,
              child: Center(child: Text('Cargando cámara...')),
            ),
          // Temporizador.
          Text('${_segundosRestantes ~/ 60}:${(_segundosRestantes % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 32)),
          // Controles.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _cargandoCamara ? null : _tomarFoto,
                child: const Text('Capturar'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _cargandoCamara ? null : _toggleTimer,
                child: Text(_timerActivo ? 'Pausar' : 'Iniciar'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _cargandoCamara ? null : _finalizar,
                child: const Text('Finalizar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
