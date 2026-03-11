# Debug: Problema de Flujo de Pago DSL

**Fecha**: 2026-01-29 (Actualizado)
**Fecha original**: 2026-01-13
**Archivo principal**: `lib/pages/checkout_page.dart`
**Función afectada**: `_procesarPagoDSL()`

---

## Problema Original

Después de crear el APK de producción (no ocurre en debug), el proceso de pago DSL:
1. Invoca el SDK correctamente
2. Hace el cobro exitosamente
3. Aparece la opción de imprimir
4. **PERO**: Aparecía `ShowAlert: "Error Procesando Pago - Código 0"` (incongruente porque código 0 = éxito)
5. El `statusId` quedaba en 0, no se procesaba el setState
6. No navegaba a Dashboard

---

## Diagnóstico Realizado

### Problema 1: Funciones async sin await (CORREGIDO)
Las funciones `_imprimirComprobante` y `_imprimirComprobanteError` eran `void async` en lugar de `Future<void> async`, causando que no se esperaran correctamente.

**Corrección aplicada:**
```dart
// Antes
void _imprimirComprobante(RecordResponse response) async { ... }

// Después
Future<void> _imprimirComprobante(RecordResponse response) async { ... }
```

### Problema 2: Variables con valor 0 (CORREGIDO)
Las variables `totalPaid`, `totalPaidBs`, `paidPuntoBs`, `paidPuntoUsd` se inicializaban en 0 en `initState` y nunca se actualizaban.

**Corrección aplicada:**
```dart
// Antes
checkout.totalPaid = totalPaid;      // totalPaid = 0
checkout.totalPaidBs = totalPaidBs;  // totalPaidBs = 0

// Después
checkout.totalPaid = getTotalAmount();
checkout.totalPaidBs = getTotalAmountBs();
checkout.paidPuntoBs = getTotalAmountBs();
checkout.paidPuntoUsd = getTotalAmount();
```

### Problema 3: Múltiples callbacks del SDK DSL (CORREGIDO)
El SDK DSL llama al callback `onTransactionResult` dos veces:
1. Primera vez: con resultado exitoso (result=0)
2. Segunda vez: ~4 segundos después con "operación cancelada"

Cuando Flutter recibe el segundo callback e intenta llamar `result.success()` o `result.error()` de nuevo, lanza una excepción que interrumpe el flujo.

**Corrección aplicada en `MainActivity.kt`:**
```kotlin
var resultSent = false

smartService!!.transactionRequest(req, object : ITransactionResultListener.Stub() {
    override fun onTransactionResult(trx: TransactionResultEntity?) {
        // Proteger contra múltiples callbacks
        if (resultSent) {
            Log.w("DSL_DEBUG", "IGNORANDO callback duplicado")
            return
        }
        resultSent = true

        runOnUiThread {
            try {
                if (trx?.result == 0) {
                    result.success(json)
                } else {
                    result.error("TRANSACTION_FAILED", json, null)
                }
            } catch (e: Exception) {
                Log.e("DSL_ERROR", "Error enviando resultado: ${e.message}")
            }
        }
    }
})
```

---

## Estado Actual del Problema

Después de las correcciones:
- El pago se procesa correctamente
- No hay errores en Crashlytics
- **PERO**: Los pasos 5 (setState) y 6 (impresión) no se ejecutan
- Regresa a la pantalla de inicio de pago en lugar de navegar a Dashboard

### Logs esperados en Crashlytics (verificar cuál es el último):
```
DSL_STEP_1: Iniciando proceso de pago
DSL_STEP_2: Guardando orden inicial sin pago
DSL_STEP_2_OK: Orden inicial guardada
DSL_STEP_3: Llamando doTransaction DSL
DSL_STEP_3_OK: doTransaction completado
DSL_STEP_4: RecordResponse recibido - result.result: X, errorCode: X
DSL_STEP_5: Pago exitoso, actualizando checkout        <-- ¿Se ejecuta?
DSL_STEP_5_OK: Checkout actualizado - statusId: X      <-- ¿Se ejecuta?
DSL_STEP_6: Imprimiendo comprobante                    <-- ¿Se ejecuta?
DSL_STEP_6_OK: Comprobante impreso
DSL_STEP_7: Guardando orden final
DSL_STEP_7_OK: Orden final guardada
DSL_STEP_8: Proceso completado exitosamente
```

---

## Hipótesis Pendientes de Investigar

### Hipótesis A: El SDK DSL está navegando/cerrando la Activity
El SDK DSL podría estar haciendo algo que causa que Flutter pierda el contexto o navegue automáticamente. Esto explicaría por qué regresa a la pantalla de inicio.

**Cómo verificar:**
- Agregar log del valor de `mounted` justo después de recibir el resultado del SDK
- Si `mounted = false`, significa que el widget fue desmontado

### Hipótesis B: El resultado del SDK no es `RecordResponse`
El `if (result is RecordResponse)` podría estar fallando silenciosamente.

**Cómo verificar:**
- Agregar log: `crashlytics.log("DSL_RESULT_TYPE: ${result.runtimeType}")`

### Hipótesis C: Interferencia del hilo del SDK
El callback del SDK podría estar ejecutándose en un hilo diferente que interfiere con Flutter.

**Posible solución a probar:**
```dart
// En _procesarPagoDSL, después de recibir el resultado:
if (result is RecordResponse) {
    // Forzar ejecución en el siguiente frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
        // Todo el código de procesamiento aquí
    });
}
```

### Hipótesis D: Mover todo el procesamiento post-pago fuera del flujo del SDK
Similar a lo que el usuario mencionó con otros SDKs:

```dart
void _procesarPagoDSL(String amount) async {
    // ... código inicial ...

    final result = await _dslService.doTransaction(...);

    // IMPORTANTE: Dejar que el SDK complete su ciclo
    await Future.delayed(Duration(milliseconds: 100));

    // Ahora procesar el resultado
    _procesarResultadoPago(result);
}

void _procesarResultadoPago(Object result) {
    // Todo el código de procesamiento aquí
}
```

---

## Archivos Modificados

### 1. `lib/pages/checkout_page.dart`
- Agregado import de `firebase_crashlytics`
- Función `_procesarPagoDSL`: Logging completo con Crashlytics
- Función `_imprimirComprobante`: Cambiado de `void` a `Future<void>`
- Función `_imprimirComprobanteError`: Cambiado de `void` a `Future<void>`
- Función `_processCheckout`: Agregado logging y verificaciones de `mounted`
- Actualizaciones de checkout movidas dentro de `setState`
- Uso de `getTotalAmount()` y `getTotalAmountBs()` en lugar de variables

### 2. `android/app/src/main/kotlin/com/fullqueso/dslqueso/MainActivity.kt`
- Función `doTransaction`: Agregada protección contra múltiples callbacks
- Bandera `resultSent` para ignorar callbacks duplicados
- Envuelto resultado en `runOnUiThread`
- Try/catch adicional para capturar excepciones

---

---

## SOLUCIÓN IMPLEMENTADA - Iteración 2 (2026-01-29 - Tarde)

### Problema encontrado después de primera solución
- El error "Código 0" desapareció ✓
- El pago se procesa correctamente ✓
- **PERO**: No redirige al Dashboard en producción (APK)
- En debug funciona perfectamente

### Causa raíz
1. **`addPostFrameCallback` con async**: El callback no maneja correctamente funciones async, el `await` no se espera realmente
2. **`ShowAlert` antes de navegar**: Bloqueaba la navegación en producción

### Correcciones aplicadas

#### 1. Cambiado `addPostFrameCallback` por `scheduleMicrotask`
```dart
// Antes
WidgetsBinding.instance.addPostFrameCallback((_) async {
  await _procesarResultadoSDK(sdkResult, sdkSuccess, sdkError);
});

// Después
scheduleMicrotask(() async {
  await _procesarResultadoSDK(sdkResult, sdkSuccess, sdkError);
});
```
`scheduleMicrotask` maneja correctamente funciones async y se ejecuta inmediatamente después del código síncrono.

#### 2. Eliminado `ShowAlert` antes de navegación
```dart
// Antes
if (mounted) {
  ShowAlert(context, "Orden procesada satisfactoriamente", 'success');
  Navigator.of(context).pushReplacement(...);
}

// Después
if (mounted) {
  Navigator.of(context).pushReplacement(...);
  crashlytics.log("CHECKOUT_PROCESS: Navigator.pushReplacement ejecutado");
}
```
La navegación ahora es directa sin interferencias de diálogos.

---

## SOLUCIÓN IMPLEMENTADA - Iteración 1 (2026-01-29 - Mañana)

### Reestructuración en 3 Fases

El código fue completamente reestructurado para separar el procesamiento del SDK del procesamiento de Flutter:

#### FASE 1: Solo interactuar con el SDK
- Captura el resultado del SDK sin procesarlo
- Almacena en variables locales: `sdkResult`, `sdkSuccess`, `sdkError`
- Cualquier excepción del SDK se captura aquí

#### FASE 2: Esperar ciclo del SDK
```dart
await Future.delayed(const Duration(milliseconds: 300));
```
- Delay de 300ms para que el SDK complete su ciclo interno
- El mensaje "operación cancelada" que aparecía después de 4 segundos ya no interfiere

#### FASE 3: Procesar en contexto limpio de Flutter
```dart
WidgetsBinding.instance.addPostFrameCallback((_) async {
  await _procesarResultadoSDK(sdkResult, sdkSuccess, sdkError);
});
```
- `addPostFrameCallback` ejecuta el código en el SIGUIENTE frame de Flutter
- Completamente desacoplado del contexto del SDK
- El procesamiento (setState, impresión, guardado, navegación) ocurre aquí

### Nueva función `_procesarResultadoSDK`

Función separada que maneja:
1. Casos de error del SDK
2. Casos de pago rechazado
3. Casos de pago exitoso (actualizar checkout, imprimir, guardar, navegar)

### Por qué esta solución debería funcionar

1. **Desacoplamiento**: El SDK ya no está "activo" cuando procesamos el resultado
2. **Frame separado**: `addPostFrameCallback` asegura que Flutter esté en un estado limpio
3. **Delay preventivo**: 300ms previene interferencia del callback tardío del SDK
4. **Sin catch que parsea JSON**: El error "Código 0" ya no puede ocurrir porque el procesamiento está separado

---

## Próximos Pasos Sugeridos

1. **Verificar logs de Crashlytics**: Identificar el último paso que se ejecuta
2. **Agregar delay después del SDK**: Probar si un pequeño delay permite que el SDK complete su ciclo
3. **Separar el procesamiento**: Mover el código post-pago a una función separada
4. **Verificar `mounted`**: Agregar logs del estado de mounted en cada punto crítico
5. **Probar con `addPostFrameCallback`**: Forzar que el procesamiento ocurra en el siguiente frame de Flutter

---

## Código Actual de `_procesarPagoDSL` (para referencia)

```dart
void _procesarPagoDSL(String amount) async {
    final crashlytics = FirebaseCrashlytics.instance;

    String numOrder = widget.ticketNumber.length > 6
        ? widget.ticketNumber.substring(widget.ticketNumber.length - 6)
        : widget.ticketNumber;

    try {
      crashlytics.log("DSL_STEP_1: Iniciando proceso de pago - monto: $amount, orden: $numOrder");

      checkout.statusId = 0;
      checkout.statusCurrent = 'Solicitado';
      checkout.totalPaid = 0;
      checkout.totalPaidBs = 0;
      checkout.paidPuntoBs = 0;
      checkout.paidPuntoUsd = 0;

      crashlytics.log("DSL_STEP_2: Guardando orden inicial sin pago");
      await _processCheckout(false);
      crashlytics.log("DSL_STEP_2_OK: Orden inicial guardada");

      String cardholderId = checkout.customerId ?? '111111';

      crashlytics.log("DSL_STEP_3: Llamando doTransaction DSL");
      final result = await _dslService.doTransaction(
        amount,
        cardholderId,
        '1',
        numOrder,
        1,
      );
      crashlytics.log("DSL_STEP_3_OK: doTransaction completado");

      if (result is RecordResponse) {
        crashlytics.log("DSL_STEP_4: RecordResponse recibido - result.result: ${result.result}, errorCode: ${result.errorCode}");

        if (result.result == 0) {
          crashlytics.log("DSL_STEP_5: Pago exitoso, actualizando checkout");

          if (mounted) {
            setState(() {
              checkout.statusId = 2;
              checkout.statusCurrent = 'Preparación';
              checkout.totalPaid = getTotalAmount();
              checkout.totalPaidBs = getTotalAmountBs();
              checkout.paidPuntoBs = getTotalAmountBs();
              checkout.paidPuntoUsd = getTotalAmount();
              checkout.terminal = result.terminalId;
              checkout.isUbii = false;
              checkout.ubiiLog = '${result.rrn} | ${result.referenceNumber}';
            });
          }
          crashlytics.log("DSL_STEP_5_OK: Checkout actualizado - statusId: ${checkout.statusId}, totalPaid: ${checkout.totalPaid}");

          crashlytics.log("DSL_STEP_6: Imprimiendo comprobante");
          try {
            await _imprimirComprobante(result);
            crashlytics.log("DSL_STEP_6_OK: Comprobante impreso");
          } catch (printError, printStack) {
            crashlytics.log("DSL_STEP_6_ERROR: Error imprimiendo comprobante: $printError");
            crashlytics.recordError(printError, printStack, reason: "Error en _imprimirComprobante");
          }

          crashlytics.log("DSL_STEP_7: Guardando orden final - statusId: ${checkout.statusId}, mounted: $mounted");
          if (!mounted) {
            crashlytics.log("DSL_STEP_7_ABORT: Widget no mounted antes de guardar");
            return;
          }
          try {
            await _processCheckout(true);
            crashlytics.log("DSL_STEP_7_OK: Orden final guardada, mounted: $mounted");
          } catch (saveError, saveStack) {
            crashlytics.log("DSL_STEP_7_ERROR: Error guardando orden final: $saveError");
            crashlytics.recordError(saveError, saveStack, reason: "Error en _processCheckout final");
            if (mounted) {
              ShowAlert(context, "Error guardando orden: $saveError", 'error');
            }
            return;
          }

          crashlytics.log("DSL_STEP_8: Proceso completado exitosamente");

        } else {
          // Pago rechazado
          crashlytics.log("DSL_STEP_REJECTED: Pago rechazado - errorCode: ${result.errorCode}");
          await _imprimirComprobanteError(result);

          if (mounted) {
            ShowAlert(context, "Error procesando pago - Código: ${result.errorCode}", 'error');
            setState(() {
              saving = false;
            });
          }
          return;
        }
      } else {
        crashlytics.log("DSL_ERROR: Respuesta no es RecordResponse - tipo: ${result.runtimeType}");
        if (mounted) {
          ShowAlert(context, "Error: Respuesta inválida del POS", 'error');
          setState(() {
            saving = false;
          });
        }
      }
    } catch (e, stackTrace) {
      crashlytics.log("DSL_CATCH: Excepción capturada: $e");
      crashlytics.recordError(e, stackTrace, reason: "Excepción en _procesarPagoDSL");
      // ... resto del manejo de errores ...
    }
}
```

---

## Notas Adicionales

- El problema SOLO ocurre en producción (APK release), no en debug
- El mensaje "operación cancelada" del dispositivo aparece ~4 segundos después del pago exitoso
- Este comportamiento sugiere que el SDK DSL tiene algún proceso en segundo plano que interfiere con Flutter
