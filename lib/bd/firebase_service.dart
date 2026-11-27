import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../validadores.dart';

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

  // Hito 3: CRUD de perfil infantil en la colección children/{childId}.
  // apoderadoUid se asigna con el usuario autenticado al crear.

  static Future<void> crearNino({
    required String nombre,
    required int edad,
    required String avatar,
  }) async {
    await _asegurarInicializacion();
    // Reutiliza validadores.dart: nombre no vacío y edad entre 7 y 12.
    final errorNombre = validarObligatorio(nombre);
    if (errorNombre != null) throw Exception(errorNombre);
    final errorEdad = validarEdad(edad.toString());
    if (errorEdad != null) throw Exception(errorEdad);
    final uid = _auth.currentUser!.uid;
    await _db.collection('children').add({
      'apoderadoUid': uid,
      'nombre': nombre,
      'edad': edad,
      'avatar': avatar,
    });
  }

  static Future<List<Map<String, dynamic>>> listarNinos() async {
    await _asegurarInicializacion();
    // Consulta filtrada por apoderadoUid (obligatoria para las reglas).
    final uid = _auth.currentUser!.uid;
    final consulta = await _db
        .collection('children')
        .where('apoderadoUid', isEqualTo: uid)
        .get();
    return consulta.docs.map((d) {
      final data = d.data();
      return {...data, 'id': d.id};
    }).toList();
  }

  static Future<void> actualizarNino({
    required String id,
    String? nombre,
    int? edad,
    String? avatar,
  }) async {
    await _asegurarInicializacion();
    final datos = <String, dynamic>{};
    if (nombre != null) {
      final error = validarObligatorio(nombre);
      if (error != null) throw Exception(error);
      datos['nombre'] = nombre;
    }
    if (edad != null) {
      final error = validarEdad(edad.toString());
      if (error != null) throw Exception(error);
      datos['edad'] = edad;
    }
    if (avatar != null) {
      datos['avatar'] = avatar;
    }
    if (datos.isNotEmpty) {
      // apoderadoUid no se incluye: nunca cambia al actualizar.
      await _db.collection('children').doc(id).update(datos);
    }
  }

  static Future<void> eliminarNino(String id) async {
    await _asegurarInicializacion();
    await _db.collection('children').doc(id).delete();
  }

  // Hito 4: guarda una sesión de cepillado en Firestore (sin imagen, solo datos de la sesión).
  static Future<void> guardarSesionCepillado({
    required String apoderadoUid,
    required String ninoId,
    required int duracionSegundos,
  }) async {
    await _asegurarInicializacion();
    await _db.collection('brushing_sessions').add({
      'apoderadoUid': apoderadoUid,
      'ninoId': ninoId,
      'duracionSegundos': duracionSegundos,
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  // Hito 5: lista las sesiones de cepillado del usuario autenticado (apoderadoUid).
  static Future<List<Map<String, dynamic>>> listarSesiones() async {
    await _asegurarInicializacion();
    final uid = _auth.currentUser!.uid;
    final consulta = await _db
        .collection('brushing_sessions')
        .where('apoderadoUid', isEqualTo: uid)
        .get();
    return consulta.docs.map((d) {
      final data = d.data();
      return {...data, 'id': d.id};
    }).toList();
  }
}
