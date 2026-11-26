# Modelo de datos - Firestore

## users/{uid}
- `correo` (string)
- `rol` (string): "apoderado", "dentista" o "nino"
- `nombre` (string)
- `apellido` (string)

## children/{childId}
- `apoderadoUid` (string): UID del apoderado dueño.
- `nombre` (string)
- `edad` (number): 7–12.
- `avatar` (string)

## brushing_sessions/{sessionId} (Hito 4)
- `apoderadoUid` (string): UID del apoderado dueño.
- `fecha` (timestamp)
- `duracion` (number): segundos de cepillado.

## Reglas de acceso
Cada documento es accesible solo por su dueño (`apoderadoUid` o `uid` según la colección).
