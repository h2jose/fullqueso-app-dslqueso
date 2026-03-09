# Guía de Integración DSL/NexGO a App Fullqueso

Esta carpeta contiene todos los archivos necesarios para integrar la funcionalidad DSL/NexGO en tu app de producción Fullqueso.

## Archivos incluidos en esta carpeta (integracion/)

1. **MainActivity.kt** - MainActivity convertido a Kotlin con integración DSL/NexGO
2. **build.gradle.kts** - Configuración de Gradle con dependencias necesarias
3. **lib/** - Carpeta completa con código Flutter necesario para la integración
4. **README_INTEGRACION.md** - Este archivo con instrucciones

## Estructura de la carpeta lib/ incluida

```
lib/
├── infrastructure/
│   ├── functions/
│   │   ├── nexgo_funtions/      # DoTransaction, PrinterPos (IMPORTANTES)
│   │   └── help_funtions/       # Helpers (transformarAmountaEntero, etc)
│   ├── models/                  # Modelos de respuesta (IMPORTANTES)
│   │   ├── record_response_model.dart        # Respuesta de transacciones
│   │   └── settlement_response_sdk_model.dart # Respuesta de cierres de lote
│   ├── theme/                   # Temas de ejemplo (opcional)
│   └── utils/                   # Utils (formateo de montos, etc)
└── presentation/                # Pantallas de ejemplo (NO necesarias - solo referencia)
    ├── screens/
    └── widgets/
```

## Pasos para integrar en tu app Fullqueso

### 1. Clonar tu app Ubii

```bash
# Clonar tu app de producción
cp -r /ruta/a/fullqueso_ubii /ruta/a/fullqueso_dsl

# O si usas git
git clone <repo-ubii> fullqueso_dsl
cd fullqueso_dsl
```

### 2. Cambiar identificadores de la app

#### a) En `android/app/build.gradle.kts`:
- **Opción 1 (RECOMENDADA):** Reemplazar COMPLETAMENTE con el archivo `build.gradle.kts` desde la carpeta llamada integracion
- **Opción 2:** Editar manualmente y cambiar:
  - `namespace = "com.fullqueso.dslqueso"`
  - `applicationId = "com.fullqueso.dslqueso"`

#### b) En `pubspec.yaml`:
```yaml
name: fullqueso_dsl
description: App Fullqueso para POS DSL/NexGO
```

#### c) En `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.fullqueso.dslqueso">

    <application
        android:label="Fullqueso DSL"
        ...
```

### 3. Limpiar código nativo de Ubii

#### a) **BORRAR** completamente el código de Ubii:
```bash
# Eliminar el MainActivity.kt de Ubii (se reemplazará con el de DSL)
rm android/app/src/main/kotlin/com/fullqueso/ubiiqueso/MainActivity.kt

# Eliminar la carpeta de paquetes de Ubii
rm -rf android/app/src/main/kotlin/com/fullqueso/ubiiqueso/
```

### 4. Instalar código nativo DSL

#### a) Crear nueva estructura de paquetes:
```bash
# Crear carpeta para el nuevo package
mkdir -p android/app/src/main/kotlin/com/fullqueso/dslqueso/
```

#### b) Copiar MainActivity.kt desde la carpeta llamada integracion:
```bash
# Copiar el MainActivity.kt nuevo
cp integracion/MainActivity.kt android/app/src/main/kotlin/com/fullqueso/dslqueso/MainActivity.kt
```

Este archivo YA TIENE:
- ✅ Package correcto: `package com.fullqueso.dslqueso`
- ✅ Canal `nexgo_service`
- ✅ Métodos: `bindService`, `doTransaction`, `printReceipt`, `printerTest`
- ✅ Integración completa con SDKs de NexGO

Y NO TIENE código de Ubii:
- ❌ `BootReceiver`
- ❌ Intent a `com.ubiipagos.pos.views.activity.MainActivityView`
- ❌ Canal `com.fullqueso.ubiiqueso/channel`

### 5. Copiar SDKs nativos (.aar)

```bash
# Desde la app de ejemplo DSL, copiar los archivos .aar
# IMPORTANTE: Ajusta la ruta según dónde tengas la app de ejemplo
cp <ruta-app-ejemplo-dsl>/android/app/libs/smartconnect_new_version.aar android/app/libs/
cp <ruta-app-ejemplo-dsl>/android/app/libs/nexgo-smartpos-sdk-v3.08.002_20240410.aar android/app/libs/
```

Estos archivos son:
- `smartconnect_new_version.aar` - SDK de SmartConnect para procesamiento de pagos
- `nexgo-smartpos-sdk-v3.08.002_20240410.aar` - SDK de NexGO para hardware (impresora)

### 6. Integrar código Flutter necesario

#### a) Copiar archivos CRÍTICOS desde la carpeta llamada integracion:

**MODELOS (OBLIGATORIOS):**
```bash
# Crear carpeta de modelos si no existe
mkdir -p lib/infrastructure/models/

# Copiar modelos de respuesta
cp integracion/lib/infrastructure/models/record_response_model.dart lib/infrastructure/models/
cp integracion/lib/infrastructure/models/settlement_response_sdk_model.dart lib/infrastructure/models/
```

**FUNCIONES NEXGO (OBLIGATORIAS):**
```bash
# Crear carpeta de funciones si no existe
mkdir -p lib/infrastructure/functions/nexgo_funtions/

# Copiar wrappers del MethodChannel
cp integracion/lib/infrastructure/functions/nexgo_funtions/*.dart lib/infrastructure/functions/nexgo_funtions/
```

**HELPERS (RECOMENDADOS):**
```bash
# Copiar helpers (como transformarAmountaEntero)
mkdir -p lib/infrastructure/functions/help_funtions/
cp integracion/lib/infrastructure/functions/help_funtions/*.dart lib/infrastructure/functions/help_funtions/
```

**UTILS (OPCIONALES):**
```bash
# Copiar utils de formateo de montos
mkdir -p lib/infrastructure/utils/
cp integracion/lib/infrastructure/utils/*.dart lib/infrastructure/utils/
```

#### b) Las clases principales que usarás:

**Para Transacciones:**
```dart
import 'package:fullqueso_dsl/infrastructure/functions/nexgo_funtions/nexgo_funtions.dart';
import 'package:fullqueso_dsl/infrastructure/models/record_response_model.dart';

// En tu código de checkout:
final transaccion = DoTransaction();

// 1. Bind al servicio
await transaccion.bindService();
await Future.delayed(const Duration(milliseconds: 500));

// 2. Ejecutar transacción
final result = await transaccion.doTransaction(
  amount: '1000',              // En centavos (1000 = 10.00 Bs)
  cardholderId: '12345678',    // CI del cliente
  waiterNum: '',
  referenceNo: 'REF001',
  transType: 1,                // 1=Venta, 4=Settlement
);

// 3. Parsear respuesta
final response = RecordResponse.fromJson(result);
if (response.result == 0) {
  // Transacción exitosa
  print('Aprobada: ${response.approvalCode}');
} else {
  // Transacción fallida
  print('Error: ${response.responseMessage}');
}
```

**Para Impresión:**
```dart
import 'package:fullqueso_dsl/infrastructure/functions/nexgo_funtions/printer_functions.dart';

final printer = PrinterPos();

// Imprimir recibo completo
await printer.printReceipt(
  fullName: 'Juan Pérez',
  ciClient: '12345678',
  amount: '10.00 Bs',
  ctaContrato: 'CTA123',
  referenceNo: 'REF001',
  fecha: '2024-12-21',
  hora: '14:30',
  lote: 'LOTE001',
  afiliado: 'AFF123',
  terminal: 'TERM001',
  serial: 'SER001',
  trace: 'TRACE001',
);
```

**Para Formateo de Montos:**
```dart
import 'package:fullqueso_dsl/infrastructure/functions/help_funtions/help_funtions.dart';

// Convertir decimal a centavos
String montoEnCentavos = transformarAmountaEntero('10.50'); // "1050"
```

### 7. Actualizar las llamadas en tu código existente

**ELIMINAR** las llamadas antiguas de Ubii:
```dart
// ❌ ELIMINAR ESTO (Ubii viejo)
static const platform = MethodChannel('com.fullqueso.ubiiqueso/channel');
await platform.invokeMethod('getResponse', {...});
```

**REEMPLAZAR** con las clases de DSL:
```dart
// ✅ USAR ESTO (DSL nuevo)
final transaccion = DoTransaction();
await transaccion.bindService();
await Future.delayed(const Duration(milliseconds: 500));
final result = await transaccion.doTransaction(...);
```

### 8. Verificar assets

El logo para la impresora debe estar en:
```
assets/images/logo-dg-blanco.png
```

Y declarado en `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/logo-dg-blanco.png
```

Si quieres usar tu propio logo, asegúrate de actualizar la ruta en `MainActivity.kt` línea 224.

### 9. Verificar permisos en AndroidManifest.xml

Probablemente ya los tienes de Ubii, pero verifica:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### 10. Compilar y probar

```bash
# Limpiar build anterior
flutter clean
flutter pub get

# Compilar
flutter build apk --debug

# O correr directamente en dispositivo NexGO
flutter run
```

## Archivos Flutter críticos (OBLIGATORIOS)

Estos archivos de la carpeta llamada integracion son OBLIGATORIOS para que funcione:

| Archivo | Ubicación | Propósito |
|---------|-----------|-----------|
| `nexgo_funtions.dart` | `lib/infrastructure/functions/nexgo_funtions/` | Wrapper del MethodChannel (DoTransaction) |
| `printer_functions.dart` | `lib/infrastructure/functions/nexgo_funtions/` | Wrapper para impresora (PrinterPos) |
| `record_response_model.dart` | `lib/infrastructure/models/` | Modelo de respuesta de transacciones |
| `settlement_response_sdk_model.dart` | `lib/infrastructure/models/` | Modelo de respuesta de settlement |
| `help_funtions.dart` | `lib/infrastructure/functions/help_funtions/` | Helper para convertir montos (transformarAmountaEntero) |

## Diferencias clave: Ubii vs DSL

| Característica | Ubii | DSL/NexGO |
|---------------|------|-----------|
| **Integración** | Intent a app externa | AIDL binding directo al SDK |
| **Canal** | `com.fullqueso.ubiiqueso/channel` | `nexgo_service` |
| **Métodos** | `getResponse` | `bindService`, `doTransaction`, `printReceipt`, `printerTest` |
| **SDKs nativos** | App POS Ubii externa | Archivos .aar en libs/ |
| **Servicio** | Lanza app Ubii | Bind directo a `cn.nexgo.veslc` |
| **Respuesta** | Intent result | JSON parseado a modelos |

## Resolución de problemas

### Error: "Failed to bind service"
- Verificar que los archivos .aar estén en `android/app/libs/`
- Verificar que el `build.gradle.kts` tenga las implementaciones correctas
- El servicio `cn.nexgo.veslc` debe estar instalado en el dispositivo NexGO
- Solo funciona en dispositivos NexGO reales, NO en emuladores

### Error: "Printer not found"
- Solo funciona en dispositivos NexGO reales
- No funcionará en emuladores ni dispositivos que no sean NexGO
- Verificar que el dispositivo tenga papel

### Error de compilación con los .aar
- Verificar que el NDK esté instalado (se instala automáticamente)
- Limpiar: `cd android && ./gradlew clean`
- Reconstruir: `flutter clean && flutter pub get`

### Error: "Class not found" o "Package does not exist"
- Verificar que el package name sea correcto: `com.fullqueso.dslqueso`
- Verificar que el MainActivity.kt esté en la ruta correcta
- Limpiar y reconstruir

### Transacción retorna error
- Verificar que el monto esté en centavos (string): "1000" para 10.00 Bs
- Usar `transformarAmountaEntero()` para convertir decimales
- Verificar que el delay de 500ms se respete después de `bindService()`
- Revisar `response.result`: 0 = éxito, != 0 = error
- Ver `response.responseMessage` para detalles del error

## Notas importantes

1. **NO toques la app Ubii original** - Está en producción en 40 dispositivos
2. **Apps completamente separadas** - Sin código compartido (por ahora)
3. **Cada app optimizada para su hardware** - Ubii para POS Ubii, DSL para POS NexGO
4. **Las pantallas de ejemplo NO son necesarias** - Harás el llamado desde tu propio checkout
5. **Solo copia los archivos críticos mencionados** - No necesitas copiar toda la carpeta presentation/
6. **Puedes modularizar después** - Si quieres extraer el core compartido en el futuro

## Próximos pasos sugeridos

1. ✅ Clonar la app Ubii
2. ✅ Aplicar todos estos cambios paso a paso
3. ✅ Copiar archivos críticos desde la carpeta llamada integracion
4. ✅ Probar en un dispositivo NexGO real
5. ⏭️ Ajustar detalles específicos según tus necesidades
6. ⏭️ Si funciona, considerar modularizar el código de negocio compartido (opcional)

## Integración desde tu checkout

Cuando estés listo para integrar desde tus pantallas de checkout, deberás:

1. Importar las clases necesarias
2. Llamar a `DoTransaction.bindService()` (solo una vez al inicio de la app)
3. Desde tu botón de pago, llamar a `DoTransaction.doTransaction()`
4. Parsear la respuesta con `RecordResponse.fromJson()`
5. Navegar a tu pantalla de éxito/error según `response.result`

**Ejemplo básico:**
```dart
// En tu checkout
onPressed: () async {
  try {
    final transaccion = DoTransaction();
    final result = await transaccion.doTransaction(
      amount: transformarAmountaEntero(totalAmount.toString()),
      cardholderId: clienteCI,
      waiterNum: '',
      referenceNo: ordenId,
      transType: 1,
    );

    final response = RecordResponse.fromJson(result);

    if (response.result == 0) {
      // Navegar a pantalla de éxito
      Navigator.pushNamed(context, '/success', arguments: response);
    } else {
      // Mostrar error
      showDialog(...);
    }
  } catch (e) {
    // Manejar error de comunicación
  }
}
```

---
**Generado desde el proyecto de ejemplo DSL - Carpeta: integracion/**
