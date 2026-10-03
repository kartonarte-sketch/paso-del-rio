# Modelo Firestore

Ruta raíz: `restaurants/paso-del-rio`.

| Subcolección | Contenido |
|---|---|
| `staff` | Usuarios autorizados para sincronizar; se administra desde la consola |
| `packages` | Paquetes, tarifas, colores y bonos |
| `products` | Carta, costo, precio, destino y stock |
| `tables` | Zona, número, estado y grupo asignado |
| `groups` | Ingresos, personas, vehículos, paquete y pago |
| `reservations` | Fecha, pax, contacto, estado y mesa |
| `orders` | Líneas, estado de producción, mesa y pago |
| `payments` | Movimientos de ingreso y cierre de mesa |

Cada documento sincronizado incorpora `_updatedAt` y `_deviceId`.

## Usuario de sincronización

1. Habilitar Email/Password en Firebase Authentication.
2. Crear un usuario exclusivo, por ejemplo `sync@dominio-del-negocio.com`.
3. Copiar su UID.
4. Crear manualmente `restaurants/paso-del-rio/staff/UID` con `{ active: true, role: "admin" }`.
5. Desplegar `firestore.rules` y `firestore.indexes.json`.

Las credenciales se guardan únicamente en `config/windows.settings.json`, archivo ignorado por Git. No deben copiarse al archivo Android ni incluirse en la APK.
