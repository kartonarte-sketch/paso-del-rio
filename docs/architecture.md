# Arquitectura offline-first

## Decisión

El sistema no depende de Internet para operar. La aplicación Windows es el nodo central dentro de una red Wi-Fi local y escucha en el puerto `8787`. Android conserva una SQLite propia, envía su cola de cambios al nodo Windows y recibe los cambios de los demás terminales.

```text
Android recepción ─┐
Android meseros ───┼── Wi-Fi local ── Windows Hub + SQLite ── Internet ── Firestore
Android cocina ────┘                        │
                                    caja e inventario
```

El router Wi-Fi debe permanecer encendido aunque no tenga salida a Internet. El PC Windows debe usar una IP reservada, por ejemplo `192.168.1.10`.

## Resolución de conflictos

- Cada cambio tiene UUID, dispositivo y fecha UTC.
- El servidor aplica `last-write-wins`; un empate se resuelve por ID de dispositivo.
- Cobros, comandas y ventas usan IDs únicos, por lo que un reintento no duplica el documento.
- Los documentos borrados se conservan como tombstones durante la sincronización.

## Responsabilidades

- SQLite: operación diaria y fuente de verdad del local.
- Hub Windows: intercambio entre terminales sin Internet.
- Firestore: respaldo remoto y futura consulta administrativa.
- Cola `outbox`: reintentos automáticos cada cinco segundos.

## Límites conscientes

Firebase para Flutter en Windows continúa marcado como beta y no se usa directamente. El nodo Windows sincroniza por las APIs REST estables de Firebase. Cloud Storage no se usa, porque no es necesario para este sistema y actualmente exige facturación para nuevos proyectos.
