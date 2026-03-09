# Contexto: Flujo de pago DSL y pendiente (rechazos)

Documento para retomar el trabajo. **Estado**: pagos exitosos OK. Rechazos: se aplicó detección por `result > 0` y por mensaje/código; validar en dispositivo que los rechazos ya no redirijan al dashboard.

---

## 1. Objetivo del flujo

- En **checkout_page.dart** la operadora cobra con tarjeta vía SDK DSL (NexGO).
- Tras `doTransaction()`:
  - **Éxito**: mensaje satisfactorio, imprimir comprobante, guardar orden, redirigir a **dashboard_page**.
  - **Rechazo**: mostrar error, imprimir comprobante de error, quedarse en checkout (sin ir al dashboard).

---

## 1.1 Por qué funciona en debug y falla en release (APK)

En **debug** (`flutter run`): el flujo de pago suele ir bien (éxito → dashboard; rechazo → error en checkout). En **release** (APK instalado en el dispositivo) aparecen el falso "Error - Código: 0" o rechazos tratados como éxito. Las causas probables:

1. **Orden y tiempo de los callbacks del SDK**  
   El SDK DSL puede enviar **dos** callbacks (éxito y luego “cancelado”, o al revés). En **debug** la app y el AIDL van más lentos; es más probable que el **primer** callback sea el de éxito (result=0) y que Android envíe `result.success()` antes que nada. En **release** la ejecución es más rápida y el orden de los callbacks puede cambiar: a veces llega primero el de result≠0, Android programa el envío del error (delay 5 s), y cuando llega el de éxito ya se ha enviado el error o el timing hace que Flutter reciba la vía “error”. Por eso en release a veces la respuesta **exitosa** llega por `result.error()` y en Flutter `approvedByChannel` queda en false.

2. **Compilación y optimización**  
   En release, Dart va en AOT y el código nativo puede estar optimizado; los `scheduleMicrotask`, el delay de 300 ms y el `runOnUiThread` en Android se ejecutan en otro orden o con otras latencias. Eso puede hacer que el “primer” resultado que ve Flutter sea el equivocado.

3. **Entorno**  
   En debug la app suele estar conectada al PC; en release es una APK sola. No es la causa directa, pero puede influir en tiempos de red, servicios en segundo plano, etc.

**Conclusión**: La diferencia no es un bug de “variables” en Flutter, sino **timing y orden de callbacks** del SDK entre build debug y release. Por eso la solución pasa por el delay en Android (dar más tiempo al callback de éxito) y en Flutter por usar `approvedByChannel` como criterio de éxito (aunque en release a veces ese valor no coincida con el cobro real por el orden de callbacks).

---

## 2. Archivos clave

| Archivo | Rol |
|--------|-----|
| **lib/pages/checkout_page.dart** | Flujo de pago: `_procesarPagoDSL` → `_procesarResultadoSDK`. Cálculo de `treatAsSuccess` y rama éxito/error. |
| **lib/infrastructure/models/record_response_model.dart** | Modelo `RecordResponse`: `result`, `errorCode`, `responseMessage`, `responseCode`, `referenceNumber`, `terminalId`, `rrn`, etc. Parsing tolerante a claves/tipos. |
| **lib/infrastructure/functions/nexgo_funtions/nexgo_funtions.dart** | `DoTransaction.doTransaction()`: MethodChannel a Android; devuelve `RecordResponse` (por success o por PlatformException con JSON en `e.message`). |
| **android/.../MainActivity.kt** | `doTransaction`: callback del SDK; si `trx?.result == 0` → `result.success(json)`; si no → espera 2 s y luego `result.error("TRANSACTION_FAILED", json, null)` para dar prioridad a un posible callback de éxito. |

---

## 3. Estado actual

### Funciona

- **Pagos exitosos**: no aparece falso "Error - Código: 0", hay mensaje satisfactorio de procesamiento y redirección a **dashboard_page**.

### Pendiente de validar en dispositivo

- **Transacciones rechazadas**: se añadió lógica para frenar (rechazo si `result > 0` o si mensaje/código indica rechazo). Probar en APK que un pago rechazado ya no redirija al dashboard.

---

## 4. Lógica actual de éxito/error (checkout_page.dart)

- **Cálculo de `sdkSuccess`** (en `_procesarPagoDSL`, tras `doTransaction()`):
  - `resultOk = (result.result == 0)`
  - `fallbackOk = (result.errorCode == 0 && result.referenceNumber.isNotEmpty)` (ya no se usa en la condición final de éxito; ver abajo)
  - `sdkSuccess = resultOk || fallbackOk`

- **En `_procesarResultadoSDK`**:
  - `isRejectionByMessage = _isRejectionResponse(responseMessage, responseCode)`  
    Función que busca en mensaje/código cadenas como: `rechaz`, `denied`, `declined`, `cancelado`, `cancel `, `fallido`, `fail`, `reject`, `invalid`, `insufficient`, `insuficiente` (case insensitive).
  - **Criterio actual**:  
    `treatAsSuccess = (sdkSuccess || sdkResult.errorCode == 0) && !isRejectionByMessage`
  - Si `!treatAsSuccess` → se muestra "Error procesando pago - Código: X", se imprime comprobante de error, `return` (no se va al dashboard).
  - Si `treatAsSuccess` → flujo de éxito (setState, imprimir comprobante, `_processCheckout(true)`, redirección a dashboard).

**Problema**: en rechazos reales, o no llega ningún texto de rechazo en `responseMessage`/`responseCode`, o llega con otro formato, así que `_isRejectionResponse` devuelve false y se considera éxito.

**Por qué volvemos al mismo problema**: El SDK puede devolver **los mismos datos** (result=0, errorCode=0) en éxito y en rechazo; la única señal fiable es **por qué vía respondió Android**: `result.success()` → éxito, `result.error()` → rechazo/cancelado. Si en Flutter permitimos éxito cuando `approvedByChannel == false` (por los datos), los rechazos se tratan como éxito. Si exigimos solo `approvedByChannel == true`, en release a veces la respuesta exitosa llega por la vía error (orden de callbacks) y aparece el falso "Error - Código: 0".

**Corrección actual (prioridad: frenar rechazos)**:
- **Éxito solo si `approvedByChannel == true`**. No se usa `dataSaysSuccess` cuando el canal dijo error; así los rechazos no van al dashboard.
- En **Android**: delay al enviar error aumentado a **5 s** (antes 2 s) cuando el primer callback tiene result!=0, para dar más margen a que llegue un callback de éxito en release y se envíe success antes que el error.
- Log Crashlytics incluye `approvedByChannel` para ver en cada caso por qué vía llegó la respuesta.

**Cómo ver los logs en Firebase Crashlytics (sin crash)**:
- En la consola de Firebase: **Crashlytics** → pestaña **Issues** (o **Problemas**).
- Los reportes no fatales aparecen como “Non-fatals” o en la lista de issues; al abrir uno se ven los **Logs** y el **reason** con el texto `result=X errorCode=X msg="..." code="..."`.
- También: **Crashlytics** → **Dashboard** → filtrar por tipo “Non-fatals” si la UI lo permite, o abrir la app/sesión y revisar los eventos recientes.
- Alternativa: en **DebugView** (Analytics) o en los **Breadcrumbs** de un evento/crash cercano pueden aparecer los `log()`; los `recordError(..., fatal: false)` suelen verse como issues propios.

---

## 5. Intentos previos (resumen)

1. **Solo `result.result == 0`**  
   En release el JSON a veces no trae `result` bien (clave/tipo), entonces `sdkSuccess` quedaba false y aparecía falso "Error - Código: 0".
2. **Añadir `errorCode == 0` como éxito**  
   Quitó el falso error pero los rechazos también se trataron como éxito (van al dashboard).
3. **Exigir “prueba” de transacción**: `errorCode == 0` **y** (`referenceNumber` + (`terminalId` o `rrn`))  
   En release el callback de éxito a veces no trae referencia/terminal/RRN, así que volvió el falso error en pagos exitosos. Se revirtió.
4. **Mantener `errorCode == 0` como éxito y detectar rechazo por `_isRejectionResponse(responseMessage, responseCode)`**  
   Estado actual: éxitos OK; rechazos siguen yendo al dashboard porque el rechazo no se detecta por mensaje/código.

---

## 6. Qué falta por hacer

- **Objetivo**: que las transacciones **no satisfactorias** no se traten como éxito: no redirigir al dashboard, mostrar error y quedarse en checkout.
- **Restricción**: no volver a exigir referencia/terminal para considerar éxito, porque en release eso rompe pagos exitosos reales.

**Pistas para continuar**

1. **Ver qué devuelve el SDK en un rechazo real**  
   - Revisar en **Crashlytics** el log `DSL_RESULT`: valores de `result`, `errorCode`, `msg`, `code` cuando la operadora hace una transacción rechazada.  
   - Con eso se puede:
     - ampliar `_isRejectionResponse` con el texto/código real, o
     - usar otro campo (p. ej. `result != 0` cuando sí llegue bien parseado en rechazo).

2. **Comprobar si en rechazo `result` sí viene distinto de 0**  
   Si en rechazo el JSON trae `result != 0` y en éxito `result == 0`, se podría:
   - considerar éxito solo cuando `(result == 0) || (errorCode == 0 && !isRejectionByMessage)`, y
   - asegurar que el modelo parsee bien `result` (ya hay parsing tolerante en `record_response_model.dart`).

3. **Probar en dispositivo** con una transacción rechazada y:
   - capturar el JSON completo que llega (log en Android del `gson.toJson(trx)` en el callback de rechazo), o
   - revisar el log de Crashlytics justo después del rechazo para ver `msg` y `code` exactos.

4. **Documentación / demo**  
   - `docs/README_INTEGRACION.md`  
   - PDF del SDK (sección RecordResponse, códigos de respuesta)  
   - Demo: `docs/disglobal_sdk_demo_for_flutter` (modelo y pantallas de aprobado/rechazado)

---

## 7. Ubicación exacta del código a tocar

- **Criterio de éxito y rechazo**:  
  **lib/pages/checkout_page.dart**  
  - Función `_isRejectionResponse` (aprox. líneas 21–32).  
  - En `_procesarResultadoSDK`: cálculo de `isRejectionByMessage` y `treatAsSuccess` (aprox. 332–348).  
- **Modelo de respuesta**:  
  **lib/infrastructure/models/record_response_model.dart** (por si hace falta leer más campos o normalizar otro).

---

## 8. Referencias rápidas

- **CLAUDE.md** (raíz del proyecto): arquitectura NexGO, flujo de pago, métodos de pago.
- **DEBUG_DSL_PAYMENT_ISSUE.md** (si existe): historial del falso error Código 0 y doble callback.
- **docs/README_INTEGRACION.md**: integración DSL/NexGO.
- **docs/disglobal_sdk_demo_for_flutter**: app demo del proveedor (SaleScreen, TransactionApprovedScreen, TransactionFailedScreen, RecordResponse).

---

*Documento generado para retomar el control de transacciones rechazadas sin afectar el flujo de pagos exitosos.*
