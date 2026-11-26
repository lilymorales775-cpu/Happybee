# Especificación: Perfil infantil

## Colección
`children/{childId}`

## Campos
- `apoderadoUid` (string): UID del apoderado autenticado que creó el registro.
- `nombre` (string): nombre del niño.
- `edad` (number): edad entre 7 y 12 años.
- `avatar` (string): identificador simple del avatar (sin subida de imágenes).

## Operaciones
- **Crear:** autenticado, `apoderadoUid = FirebaseAuth.currentUser.uid`.
- **Listar:** solo los documentos donde `apoderadoUid == uid` del usuario autenticado.
- **Editar:** solo el apoderado dueño; `apoderadoUid` no puede cambiar.
- **Eliminar:** solo el apoderado dueño.

## Validaciones
- Nombre: no vacío (`validarObligatorio`).
- Edad: entero entre 7 y 12 (`validarEdad`).
