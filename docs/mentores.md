# Mentores e inversores

Desde la cuenta, abrir **Conectar con mentores e inversores**. También se puede entrar desde el reporte TAM. El catálogo incluye tres perfiles de ejemplo basados en los diseños proporcionados. No representan perfiles verificados ni destinatarios reales.

Las pantallas Flutter nativas usan los colores de los HTML de Stitch, fuentes Inter y Plus Jakarta Sans incluidas con licencia OFL, y las URLs originales de los retratos y del logo. Las imágenes muestran iniciales o un icono si el servidor no responde. Para funcionamiento sin conexión se necesitan los archivos de imagen originales como assets locales.

## Desarrollo

API, en `server`:

```sh
npm ci
DATABASE_FILE=/workspace/.proyectomovil/app.sqlite npm start
```

Crear primero el directorio de la base de datos. No ejecutar el servidor en paralelo con `tests/server.test.js`, que usa el puerto 3000.

Flutter (SDK con Dart >=3.11, según el lockfile), en `mobile/green_hat_app`:

```sh
flutter pub get --enforce-lockfile
flutter analyze
flutter test test/mentors_screen_test.dart
flutter build web
flutter run -d web-server --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

En emulador Android usar `--dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1`. En dispositivo físico configurar una URL de API accesible desde el dispositivo. Para producción usar HTTPS.

## Contrato añadido

Todos los endpoints requieren el Bearer token de la sesión existente.

- `GET /api/v1/mentors?q=...&category=...`: búsqueda y filtro combinados.
- `GET /api/v1/mentors/:id`: detalle del perfil.
- `POST /api/v1/mentors/:id/requests`: `{type, message, shareReport, report?}`. Tipos: `feedback`, `mentoring`, `pitch`. Mensaje no vacío, hasta 240 caracteres visibles. El usuario propietario proviene del token; no se acepta un identificador enviado por el cliente.

La autorización para adjuntar el reporte empieza desactivada en cada detalle. El servidor rechaza un adjunto sin `shareReport: true`. Se guarda una copia autorizada en SQLite; el catálogo no expone solicitudes ni reportes. El reporte TAM actual contiene valores de ejemplo y se identifica como tal al adjuntarlo. Las solicitudes solo se registran: no se implementa entrega a personas, correo o bandeja de mentores.

## Validación en este entorno

```sh
cd server
npm test -- --runInBand tests/mentors.test.js tests/unit.test.js tests/server.test.js
```

Las suites históricas que importan `tests/helpers.js` siguen bloqueadas porque falta `openapi.yaml` en la raíz del repositorio. `test/widget_test.dart` también conserva un test de contador de la plantilla anterior a esta funcionalidad.

Flutter no está instalado en la máquina y el proxy rechaza `storage.googleapis.com` con HTTP 403. Por ello no se han ejecutado el análisis de tipos, las pruebas Flutter ni la compilación ni la comparación visual. La comprobación de sintaxis Dart independiente no sustituye esas validaciones.
