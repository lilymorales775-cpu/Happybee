# Requerimientos - HappyBee

## MVP
App móvil Flutter para el control de higiene dental infantil.
Roles: apoderado, dentista, niño.

## Requerimientos funcionales
- Registro e inicio de sesión con correo y contraseña (Firebase Auth).
- Cierre de sesión.
- Perfil del apoderado.
- CRUD de perfil infantil (apoderado): crear, listar, editar, eliminar niños.
  - Campos: apoderadoUid, nombre, edad (7–12), avatar.
- Guía de cepillado de 2 minutos con temporizador y movimientos visuales (Hito 4).
- Captura con cámara real durante la sesión de cepillado (Hito 4).
- Historial de sesiones de cepillado (Hito 5).

## Requerimientos no funcionales
- Autenticación y autorización con Firebase.
- Reglas de seguridad en Firestore: solo el dueño accede a sus datos.
- Persistencia de datos en Firestore.
- Disponible para Android.

## Fuera de alcance del MVP
- Firebase Storage (imágenes de avatar, capturas de cámara) se añade en Hito 4.
- Diseño visual avanzado.
