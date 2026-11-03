# Mentores e inversores

Desde el dashboard principal, abrir **Explorar mentores**. También se puede entrar desde el reporte TAM. El catálogo incluye tres perfiles de ejemplo basados en los diseños proporcionados. No representan perfiles verificados ni destinatarios reales.

El dashboard, implementado en `mobile/green_hat_app/lib/screens/home_page.dart`, muestra el primer nombre del usuario, su sector, la etapa de su proyecto y una recomendación según esa etapa. Reutiliza los datos de `AccountProvider` y permite abrir la calculadora TAM y las pantallas de mentores existentes. El botón de perfil muestra los datos de la cuenta y permite cerrar sesión.

Las pantallas Flutter nativas comparten la configuración de `mobile/green_hat_app/lib/theme/app_theme.dart`. La app usa `ThemeMode.system` para seguir la preferencia clara u oscura del dispositivo o navegador. El modo oscuro utiliza el fondo azul oscuro y los acentos cian y verde de la red de mentores; el modo claro utiliza fondos claros y verdes. La adaptación también incluye acceso, registro, bienvenida, carga, calculadora, reporte y perfil.

Se mantienen las fuentes Inter y Plus Jakarta Sans incluidas con licencia OFL y las URLs originales de los retratos y del logo. Las imágenes muestran iniciales o un icono si falla su carga. Para funcionamiento sin conexión se necesitan los archivos de imagen originales como assets locales.

## Desarrollo

API, desde `server`, en PowerShell:

```powershell
npm ci
npm start
```

Por defecto, el servidor escucha en el puerto 3000 y utiliza `app.sqlite` en su directorio de ejecución. Si se configura otra ruta mediante `DATABASE_FILE`, crear primero el directorio de destino. No ejecutar el servidor en paralelo con `tests/server.test.js`, que usa el puerto 3000.

Flutter (SDK con Dart >=3.11 y Flutter >=3.38.4, según el lockfile), desde `mobile/green_hat_app`:

```powershell
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub
flutter run -d web-server --no-pub --web-port=7357 --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

Con el servidor y Flutter en ejecución, abrir `http://localhost:7357`, iniciar sesión y completar la selección de etapa si aparece la bienvenida. Desde el dashboard se pueden probar la calculadora, la red de mentores y el perfil. Para comprobar la adaptación visual, cambiar la preferencia clara u oscura del sistema.

Si Windows indica que los plugins requieren soporte para enlaces simbólicos, habilitar el modo de desarrollador y repetir la preparación de dependencias. Después de cambios en la configuración del tema, reiniciar la aplicación desde la terminal de Flutter con `R` mayúscula.

Para generar la compilación web se puede ejecutar `flutter build web --no-pub`. Su ejecución no formó parte de esta validación.

En emulador Android usar `--dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1`. En dispositivo físico configurar una URL de API accesible desde el dispositivo. Para producción usar HTTPS.

## Contrato añadido

Todos los endpoints requieren el Bearer token de la sesión existente.

- `GET /api/v1/mentors?q=...&category=...`: búsqueda y filtro combinados.
- `GET /api/v1/mentors/:id`: detalle del perfil.
- `POST /api/v1/mentors/:id/requests`: `{type, message, shareReport, report?}`. Tipos: `feedback`, `mentoring`, `pitch`. Mensaje no vacío, hasta 240 caracteres visibles. El usuario propietario proviene del token; un identificador enviado por el cliente no cambia el propietario de la solicitud.

La autorización para adjuntar el reporte empieza desactivada en cada detalle. El servidor rechaza un adjunto sin `shareReport: true`. Se guarda una copia autorizada en SQLite; el catálogo no expone solicitudes ni reportes. El reporte TAM actual contiene valores de ejemplo y se identifica como tal al adjuntarlo. Las solicitudes solo se registran: no se implementa entrega a personas, correo o bandeja de mentores.

La integración del dashboard y la adaptación del tema conservaron los endpoints existentes, la lógica del servidor y los valores fijos temporales del reporte TAM.

## Validación en este entorno

Desde la raíz del proyecto, para las suites del servidor que no dependen del contrato ausente:

```powershell
cd server
npm test -- --runInBand tests/mentors.test.js tests/unit.test.js tests/server.test.js
```

Las suites de mentores, configuración y arranque sumaron **23 pruebas aprobadas**. La ejecución completa de las pruebas del servidor deja **cinco suites bloqueadas** porque importan `tests/helpers.js` y falta `openapi.yaml` en la raíz del repositorio.

Desde `mobile/green_hat_app`:

```powershell
flutter analyze --no-pub
flutter test --no-pub
```

Flutter está instalado en este entorno. El análisis estático terminó sin problemas reportados y aprobaron las **23 pruebas de Flutter**, independientes de las 23 pruebas del servidor:

- `test/widget_test.dart`: 11 pruebas del dashboard y del flujo de acceso. Comprueban la personalización, las recomendaciones por etapa, la navegación a la calculadora, la consulta del perfil, el cierre de sesión y la ausencia de desbordamientos en anchos de 320, 390 y 1200 píxeles. Sustituyen el test de contador de la plantilla.
- `test/theme_test.dart`: 7 pruebas del modo claro y oscuro en dashboard, perfil, mentores y reporte, además de la conservación de la sesión y la navegación al cambiar el tema del sistema.
- `test/mentors_screen_test.dart`: 3 pruebas de filtros, consentimiento para adjuntar el reporte y manejo de errores al registrar solicitudes.
- `test/welcome_screen_test.dart`: 2 pruebas de personalización y selección de etapa.

Las pruebas de interfaz utilizan datos y servicios simulados. No sustituyen una prueba manual completa con la API en ejecución. No se ejecutó la compilación web ni una comparación visual formal durante esta revisión.
