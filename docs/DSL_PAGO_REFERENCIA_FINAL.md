# Referencia: Flujo de pago DSL (resumen de lo que funciona)

Documento de referencia del estado actual del cobro con tarjeta vía SDK NexGO/DSL.

---

## Comportamiento actual (validado)

| Caso | Resultado |
|------|-----------|
| **Pago rechazado** (ej. código de tarjeta erróneo) | SDK rechaza → vuelve a la app → se muestra alerta de error (puede aparecer "Código: 0" por incongruencia del SDK) → se queda en pantalla de checkout. No guarda ni redirige. |
| **Pago exitoso** | SDK acepta → vuelve a la app → alerta de pago exitoso → guarda orden → redirección a Dashboard. |

La incongruencia "Error - Código: 0" en rechazos es conocida: el SDK devuelve `errorCode: 0` también en rechazo; el flujo se basa en la vía del canal (success vs error), no solo en el código.

---

## Archivos clave

- **lib/pages/checkout_page.dart** – `_procesarPagoDSL`, `_procesarResultadoSDK`. Criterio de éxito: `approvedByChannel == true` y datos coherentes.
- **lib/infrastructure/functions/nexgo_funtions/nexgo_funtions.dart** – `DoTransaction.doTransaction()` devuelve `DslTransactionResult(response, approvedByChannel)`. `approvedByChannel`: true si Android llamó `result.success()`, false si llamó `result.error()`.
- **lib/infrastructure/models/record_response_model.dart** – `RecordResponse` con parsing tolerante a claves/tipos (result, errorCode).
- **android/.../MainActivity.kt** – Callback del SDK: si `trx?.result == 0` → `result.success(json)`; si no → delay 5 s y luego `result.error("TRANSACTION_FAILED", json)`. Delay para dar prioridad a un posible callback de éxito en release.

---

## Regla de éxito en Flutter

- **Éxito** solo si `approvedByChannel == true` (la respuesta llegó por `result.success()` en Android).
- Además: `allowedByData` (result==0 o -1 con errorCode==0) y no rechazo por mensaje ni por `result > 0`.
- No se usa "dataSaysSuccess" cuando el canal envió error: así los rechazos no se tratan como éxito aunque el SDK devuelva result/errorCode igual que en éxito.

---

## Por qué debug vs release se comporta distinto

En **debug** el primer callback del SDK suele ser el correcto (éxito o rechazo). En **release** (APK) el orden de callbacks puede cambiar por tiempos de ejecución; a veces la respuesta exitosa llega por la vía de error y aparecía el falso "Error - Código: 0". Por eso en Android se espera 5 s antes de enviar error cuando result≠0, para dar margen al callback de éxito.

---

## Otros ajustes incluidos

- **BootReceiver**: eliminado del `AndroidManifest.xml` (clase no existía, causaba crash al arranque).
- **flutter_native_splash**: en `dependencies` (no en dev_dependencies) para que el release compile.
- **Crashlytics**: log/reporte no fatal con `approvedByChannel`, result, errorCode, msg, code para diagnóstico.

---

## Comandos útiles

```bash
flutter pub get
flutter build apk
```

Para regenerar splash: `flutter clean && flutter pub get && flutter pub run flutter_native_splash:create`
