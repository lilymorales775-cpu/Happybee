# HappyBee

App para el cuidado y la educación de los dientes para niños entre 7 y 12 años.

## Estructura
- `lib/main.dart`: punto de entrada, inicializa Firebase.
- `lib/pages/`: pantallas de la app (bienvenida, login, registro, tipo de usuario, homes, perfil, cepillado, historial).
- `lib/bd/firebase_service.dart`: servicio de Firestore y Firebase Auth.
- `lib/validadores.dart`: validadores de formularios.
- `firestore.rules`: reglas de seguridad de Firestore.

## Requisitos
- Flutter SDK instalado.
- Proyecto Firebase con Authentication y Firestore habilitados.
- `google-services.json` en `android/app/`.

## Ejecutar
```bash
flutter pub get
flutter run
```

## Hitos
- Hito 2: registro, login, logout y protección de rutas.
- Hito 3: CRUD de perfil infantil en `children/{childId}` y reglas de Firestore.
- Hito 4: guía de cepillado de 2 minutos, temporizador, captura con cámara y registro de sesión en `brushing_sessions`.
- Hito 5: panel e historial de sesiones, pruebas y documentación.
