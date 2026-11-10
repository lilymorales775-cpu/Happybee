import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static Future<void> _asegurarInicializacion() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  static Future<void> registrarUsuario({
    required String correo,
    required String contrasena,
    required Map<String, dynamic> datos,
  }) async {
    await _asegurarInicializacion();
    final correoLimpio = correo.trim().toLowerCase();
    final cred = await _auth.createUserWithEmailAndPassword(
      email: correoLimpio,
      password: contrasena,
    );
    try {
      await _db.collection('usuarios').doc(cred.user!.uid).set({
        ...datos,
        'correo': correoLimpio,
      });
    } catch (_) {
      try {
        await cred.user?.delete();
      } catch (_) {
        await _auth.signOut();
      }
      rethrow;
    }
    await _auth.signOut();
  }

  static Future<bool> registrarNino({
    required String correo,
    required String contrasena,
    required String correoApoderado,
    required Map<String, dynamic> datos,
  }) async {
    await _asegurarInicializacion();
    final correoLimpio = correo.trim().toLowerCase();
    final cred = await _auth.createUserWithEmailAndPassword(
      email: correoLimpio,
      password: contrasena,
    );
    final uid = cred.user!.uid;

    try {
      final consulta = await _db
          .collection('usuarios')
          .where('correo', isEqualTo: correoApoderado.trim().toLowerCase())
          .get();
      final apoderados = consulta.docs
          .where((d) => d.data()['rol'] == 'apoderado')
          .toList();

      if (apoderados.isEmpty) {
        await cred.user!.delete();
        return false;
      }

      await _db.collection('usuarios').doc(uid).set({
        'nombre': datos['nombre'],
        'apellido': datos['apellido'],
        'correo': correoLimpio,
        'rol': 'nino',
      });
      await _db.collection('ninos').doc(uid).set({
        ...datos,
        'apoderadoId': apoderados.first.id,
      });
    } catch (_) {
      try {
        await cred.user?.delete();
      } catch (_) {
        await _auth.signOut();
      }
      rethrow;
    }
    await _auth.signOut();
    return true;
  }

  static Future<String?> iniciarSesion(String correo, String contrasena) async {
    await _asegurarInicializacion();
    final cred = await _auth.signInWithEmailAndPassword(
      email: correo.trim().toLowerCase(),
      password: contrasena,
    );
    final doc = await _db.collection('usuarios').doc(cred.user!.uid).get();
    if (!doc.exists) {
      await _auth.signOut();
      return null;
    }
    return doc.data()!['rol'] as String;
  }

  static Future<Map<String, dynamic>> obtenerPerfil() async {
    await _asegurarInicializacion();
    final doc = await _db
        .collection('usuarios')
        .doc(_auth.currentUser!.uid)
        .get();
    return doc.data()!;
  }

  static Future<List<Map<String, dynamic>>> listarHijos() async {
    await _asegurarInicializacion();
    final consulta = await _db
        .collection('ninos')
        .where('apoderadoId', isEqualTo: _auth.currentUser!.uid)
        .get();
    return consulta.docs.map((d) => d.data()).toList();
  }

  static Future<List<Map<String, dynamic>>> listarPacientesNinos() async {
    await _asegurarInicializacion();
    final consulta = await _db.collection('ninos').get();
    final pacientes = consulta.docs.map((documento) {
      final datos = documento.data();
      final nacimiento = datos['fechaNacimiento'];
      return {
        ...datos,
        'id': documento.id,
        if (nacimiento is Timestamp) 'fechaNacimiento': nacimiento.toDate(),
      };
    }).toList();
    pacientes.sort((a, b) {
      final nombreA = '${a['apellido'] ?? ''} ${a['nombre'] ?? ''}';
      final nombreB = '${b['apellido'] ?? ''} ${b['nombre'] ?? ''}';
      return nombreA.toLowerCase().compareTo(nombreB.toLowerCase());
    });
    return pacientes;
  }

  static Future<void> cerrarSesion() async {
    await _asegurarInicializacion();
    await _auth.signOut();
  }
}
