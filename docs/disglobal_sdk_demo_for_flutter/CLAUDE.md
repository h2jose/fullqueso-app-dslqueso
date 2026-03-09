# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter demo application for integrating with the DisGlobal SDK for POS (Point of Sale) payment terminals. The app demonstrates how to:
- Process payment transactions via NexGO devices
- Print receipts using the POS printer
- Perform settlement operations (batch closures)

The integration uses platform channels to communicate between Flutter (Dart) and the native Android SDK.

## Architecture

### Platform Channel Communication

The app uses a single `MethodChannel` named `nexgo_service` (defined in both `lib/infrastructure/functions/nexgo_funtions/nexgo_funtions.dart` and `android/app/src/main/java/com/example/disglobal_sdk_demo_for_flutter/MainActivity.java`).

**Available methods:**
- `bindService` - Binds to the SmartConnect service required for transactions
- `doTransaction` - Executes payment transactions (sales, refunds, settlements)
- `printReceipt` - Prints a full transaction receipt
- `printerTest` - Prints a test receipt with logo from assets

### Key Directories

```
lib/
├── infrastructure/
│   ├── functions/
│   │   ├── nexgo_funtions/      # Platform channel wrappers (DoTransaction, PrinterPos)
│   │   └── help_funtions/       # Helper utilities
│   ├── models/                  # Data models for SDK responses
│   │   ├── record_response_model.dart        # Transaction response model
│   │   └── settlement_response_sdk_model.dart # Settlement response model
│   ├── theme/                   # App theming
│   └── utils/                   # Utility functions (amount formatting)
└── presentation/
    ├── screens/                 # Screen components for each flow
    └── widgets/                 # Reusable UI components
```

### Transaction Flow

1. User initiates a transaction from `SaleScreen`
2. `DoTransaction.bindService()` connects to the SmartConnect service
3. `DoTransaction.doTransaction()` invokes the native Android method with parameters:
   - `amount` - Transaction amount as string (in centavos/cents)
   - `cardholderId` - Card holder's ID/document number
   - `waiterNum` - Waiter number (optional)
   - `referenceNo` - Reference number (optional)
   - `transType` - Transaction type (1=Sale, 4=Settlement)
4. Android native code communicates with the NexGO SDK via AIDL
5. Response is serialized to JSON and returned to Flutter
6. Flutter deserializes to `RecordResponse` or `SettlementResponse`
7. User is navigated to success/failure screen based on `result` field (0 = success)

### Native Android Integration

The Android implementation (`MainActivity.java`) uses:
- **SmartConnect SDK** (`smartconnect_new_version.aar`) - For payment processing
- **NexGO POS SDK** (`nexgo-smartpos-sdk-v3.08.002_20240410.aar`) - For device hardware access (printer)
- **AIDL service binding** to `cn.nexgo.veslc` package for transaction processing

Both AAR files are located in `android/app/libs/` and must be present for the app to function.

## Development Commands

### Running the app
```bash
flutter run
```

### Building
```bash
# Debug APK
flutter build apk --debug

# Release APK (requires proper signing configuration)
flutter build apk --release
```

### Running tests
```bash
flutter test
```

### Code analysis
```bash
flutter analyze
```

### Dependency management
```bash
# Install/update dependencies
flutter pub get

# Check for outdated packages
flutter pub outdated
```

## Important Notes

### Amount Formatting
Amounts must be converted to integer strings representing centavos (e.g., "1000" for 10.00 Bs). Use the `transformarAmountaEntero()` function from `lib/infrastructure/functions/help_funtions/help_funtions.dart` to convert decimal amounts.

### Service Binding Delay
After calling `bindService()`, a 500ms delay is recommended before executing transactions to ensure the service connection is established:
```dart
await transaccion.bindService();
await Future.delayed(const Duration(milliseconds: 500));
```

### Transaction Types
- `1` - Sale (purchase)
- `4` - Settlement (batch closure)

### Error Handling
Both successful and failed transactions return through the platform channel. Check the `result` field:
- `result == 0` - Transaction successful
- `result != 0` - Transaction failed (check `errorCode` and `responseMessage`)

### Assets
The app uses images from `assets/images/` which must be declared in `pubspec.yaml`. The printer functionality loads the logo from `assets/images/logo-dg-blanco.png`.

## Navigation Routes

Defined in `lib/main.dart`:
- `/` - Home screen (main menu)
- `do-transaction` - Payment transaction screen
- `printer` - Printer test screen
- `do-settlement` - Settlement/closure screen
