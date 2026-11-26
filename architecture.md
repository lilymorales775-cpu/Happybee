# Arquitectura - HappyBee

## Capas
- **UI:** `lib/pages/` con pantallas de Flutter (bienvenida, login, registro, tipo de usuario, home del apoderado, perfil, cerrar sesión).
- **Servicio de datos:** `lib/bd/firebase_service.dart` con Firebase Auth y Cloud Firestore.
- **Validadores:** `lib/validadores.dart` con funciones de validación de formularios.
- **Entrada:** `lib/main.dart` inicializa Firebase y lanza `MainApp`.

## Servicios externos
- Firebase Authentication: registro, login, logout, usuario actual.
- Cloud Firestore: persistencia de usuarios, perfiles infantiles y sesiones de cepillado.

## Flujo de autenticación
1. `main.dart` inicializa Firebase y muestra `BienvenidaPage`.
2. El usuario elige su rol y accede a login o registro.
3. `iniciarSesion` devuelve el rol del usuario desde `users/{uid}`.
4. Según el rol, se muestra el home correspondiente.
