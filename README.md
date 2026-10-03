# Paso del Río

Aplicación Flutter para Android y Windows, basada en el prototipo HTML entregado. Incluye recepción, reservas, mesas, comandas, producción, caja, barra, inventario y administración.

## Arranque rápido

1. Copiar `config/windows.settings.example.json` como `config/windows.settings.json`.
2. Copiar `config/android.settings.example.json` como `config/android.settings.json`.
3. Reservar una IP fija para el PC Windows en el router y escribirla como `HUB_URL` en la configuración Android.
4. Usar el mismo `HUB_SECRET` largo en Windows y Android.
5. Ejecutar `powershell -ExecutionPolicy Bypass -File scripts/run_windows.ps1`.
6. Generar Android con `powershell -ExecutionPolicy Bypass -File scripts/build_android.ps1`.

La APK queda en `build/app/outputs/flutter-apk/app-release.apk`.

## PWA (web)

La app web es una PWA: se puede abrir en el navegador, instalar en el teléfono
o escritorio, y revisar cada proceso con un enlace.

Vista local:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/run_pwa.ps1
```

Abre `http://localhost:59420`. Tras el login, cada módulo queda en:

- `http://localhost:59420/#/dashboard`
- `http://localhost:59420/#/recepcion`
- `http://localhost:59420/#/reservas`
- `http://localhost:59420/#/eventos`
- `http://localhost:59420/#/mesas`
- `http://localhost:59420/#/comandas`
- `http://localhost:59420/#/produccion`
- `http://localhost:59420/#/caja`
- `http://localhost:59420/#/barra`
- `http://localhost:59420/#/admin`

En la versión PWA web, los datos persisten localmente en el navegador (`localStorage`), permitiendo crear grupos, reservas, mesas y comandas sin que se borren al recargar.

### Despliegue en línea (Firebase Hosting)

El proyecto se encuentra publicado en vivo en:
**[https://paso-del-rio-hotel.web.app](https://paso-del-rio-hotel.web.app)**

Para volver a compilar y publicar las últimas actualizaciones:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/deploy_pwa.ps1
```

Repositorio en GitHub:
**[https://github.com/kartonarte-sketch/paso-del-rio](https://github.com/kartonarte-sketch/paso-del-rio)**

## Accesos iniciales

- Administrador: `admin123`
- Recepción: `recep123`
- Mesero: `mesero123`
- Cocina/barra: `cocina123`

Estos PIN son de instalación y deben cambiarse antes de producción.

## Firebase

Crear un proyecto Spark, habilitar Authentication por email/contraseña y Cloud Firestore. Seguir `docs/firebase_schema.md`, completar las variables `FIREBASE_*` solo en `windows.settings.json` y desplegar reglas con:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/deploy_firebase.ps1 -ProjectId ID_DEL_PROYECTO
```

## Verificación

```powershell
D:\AppsMoviles\flutter\bin\flutter.bat pub get
D:\AppsMoviles\flutter\bin\flutter.bat analyze
D:\AppsMoviles\flutter\bin\flutter.bat test
```

Consulte `docs/architecture.md` para la topología offline-first y las decisiones de sincronización.
