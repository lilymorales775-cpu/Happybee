# Plan de pruebas

## Casos de prueba
1. Registro de usuario nuevo (apoderado).
2. Inicio de sesión con credenciales válidas.
3. Cierre de sesión y redirección a bienvenida.
4. Crear perfil infantil con nombre, edad y avatar válidos.
5. Listar solo los niños del apoderado autenticado.
6. Editar nombre, edad y avatar de un niño existente.
7. Eliminar un niño.
8. Cerrar y reabrir la app: los datos persisten.
9. Intento de acceso a un `children` ajeno desde otro usuario: debe denegarse.
10. Validación: nombre vacío muestra error.
11. Validación: edad fuera de 7–12 muestra error.

## Evidencia mínima
- Video/capturas de registro e inicio de sesión.
- Capturas de usuarios en Firebase Authentication.
- Video/capturas de CRUD de niño.
- Captura de documento en Firestore Console.
- Prueba de bloqueo de acceso ajeno.
