# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **UBIIqueso**, a Flutter mobile application for the Fullqueso restaurant chain. It's a point-of-sale (POS) and ordering system that allows staff to manage products, orders, and checkout processes. The app integrates with Firebase for authentication, database, and crash reporting.

## Development Commands

### Essential Flutter Commands
- **Build/Run**: `flutter run` (development), `flutter build apk` (Android release)
- **Clean**: `flutter clean && flutter pub get` (when dependencies are problematic)
- **Analyze**: `flutter analyze` (static code analysis)
- **Test**: `flutter test` (run unit tests)
- **Splash Screen**: `flutter clean && flutter pub get && flutter pub run flutter_native_splash:create` (regenerate splash screen)

### Firebase Configuration
- **Android Configuration**: `android/app/google-services.json` (Firebase project: fullqueso-menu)
- **Hosting**: Firebase hosting configured for web deployment at expressqueso.web.app

## Architecture Overview

### Core Application Structure
- **Entry Point**: `lib/main.dart` - Firebase initialization, crash reporting setup, and app routing
- **State Management**: Uses Flutter's built-in state management with StatefulWidgets
- **Authentication**: Firebase Auth with automatic route handling (authenticated users go to `/dashboard`)
- **Backend**: REST API integration via HTTP requests to external backend (`uriBase` constant)

### Key Directories

#### `/lib/models/`
Data models for the application:
- `product.dart` - Product catalog structure
- `order.dart` - Order management and history
- `user.dart` - User authentication and profiles
- `checkout.dart` - Shopping cart and payment processing
- `shop.dart` - Shop/restaurant configuration

#### `/lib/services/`
Business logic and external integrations:
- `cart_service.dart` - Shopping cart calculations (USD/Bolívares conversion)
- `shared_service.dart` - App-wide shared data (shop info, user preferences)
- `rate_service.dart` - Currency exchange rate fetching
- `order_service.dart` - Order processing and management
- `customer_service.dart` - Customer data handling
- `user_service.dart` - User authentication flows

#### `/lib/components/`
Reusable UI components organized by feature:
- `cart/` - Shopping cart display and interactions
- `checkout/` - Payment and order completion UI
- `common/` - Shared widgets (app bars, loading states, alerts)
- `form/` - Form inputs and validation
- `lastorders/` - Order history display

#### `/lib/pages/`
Main application screens:
- `home_page.dart` - Login/authentication screen
- `dashboard_page.dart` - Main product catalog and ordering interface
- `checkout_page.dart` - Payment and order finalization
- `last_orders_page.dart` - Order history management
- `printer_page.dart` - Receipt/order printing functionality

### Key Technical Patterns

#### API Integration
- Base URL configuration in `lib/utils/constants.dart`
- HTTP client for REST API communication
- JSON serialization/deserialization for data models
- Error handling and loading states throughout UI

#### Data Flow
1. **Authentication**: Firebase Auth → Route determination
2. **Product Loading**: API fetch → Local state → UI rendering
3. **Cart Management**: Local state → Real-time calculations → Checkout
4. **Order Processing**: Form validation → API submission → Success/error handling

#### Firebase Integration
- **Auth**: User login/logout with session persistence
- **Crashlytics**: Automatic error reporting and crash analytics
- **Database**: Real-time product and order synchronization

## NexGO Hardware Integration

This application runs on **NexGO POS terminals** and integrates with NexGO's native SDKs for payment processing and receipt printing.

### Hardware Components
- **Device**: NexGO POS Terminal (Android-based)
- **Payment SDK**: DSL SmartConnect Service (AIDL-based)
- **Printer**: NexGO hardware thermal printer via APIProxy
- **Communication**: Flutter MethodChannel (`nexgo_service`)

### Payment Processing (DSL SDK)

#### Architecture
The payment system uses a three-layer architecture:

1. **Flutter Layer** (`lib/pages/checkout_page.dart`)
   - Main checkout page with DSL payment integration
   - Handles payment initiation, success/error flows
   - Manages receipt printing after transactions

2. **Flutter Bridge** (`lib/infrastructure/functions/nexgo_funtions/nexgo_funtions.dart`)
   - `DoTransaction` class: Wrapper for payment operations
   - `bindService()`: Initializes DSL service connection
   - `doTransaction()`: Processes card payments via MethodChannel
   - Returns `RecordResponse` model with transaction results

3. **Native Android** (`android/app/src/main/kotlin/com/fullqueso/dslqueso/MainActivity.kt`)
   - Binds to DSL SmartConnect AIDL service
   - Communicates with payment terminal hardware
   - Returns transaction results as JSON

#### Payment Flow
1. User initiates checkout from `checkout_page.dart`
2. DSL service binding verified (must be bound on app start)
3. Transaction request sent with: amount, cardholderId, waiterNum, referenceNo, transType
4. Payment terminal displays card prompts to customer
5. Transaction result returned via callback
6. Success (result=0): Print receipt, save to Firebase, navigate to dashboard
7. Failure (result≠0): Print error receipt with error code, show error alert

#### Transaction Types
- `1`: Purchase/Sale (default)
- `2`: Refund
- `4`: Settlement (end of day)

#### Response Model
`RecordResponse` (lib/infrastructure/models/record_response_model.dart):
- `result`: 0=success, other=error
- `errorCode`: Numeric error code
- `responseMessage`: Human-readable message
- `amount`, `date`, `time`, `batchNum`, `traceNumber`: Transaction details
- `rrn`: Retrieval Reference Number
- `terminalId`, `merchantId`, `deviceSerial`: Terminal identification

#### Error Handling
- **SERVICE_NOT_BOUND**: DSL service not initialized - app restart required
- **REMOTE_EXCEPTION**: Communication error with payment service
- **TRANSACTION_FAILED**: Payment declined/failed - error receipt printed
- All errors display: "Error procesando pago - Código: X"

### Printer System

#### Printer Classes
The printer system is implemented in two classes within `nexgo_funtions.dart`:

1. **DoTransaction** (payment-related printing)
   - Used after DSL payment transactions only
   - Not accessible for general printing purposes

2. **PrinterPos** (general printing)
   - Available for all printing needs
   - Methods: `imprimirPos()`, `imprimirTestPos()`, `imprimirOrdenServicio()`

#### Receipt Types

**1. Payment Success Receipt** (`imprimirPos()`)
- Printed after successful DSL card payments
- Location: `checkout_page.dart:_imprimirComprobante()`
- Format: Full payment details with cardholder info, amount, transaction IDs

**2. Payment Error Receipt** (`imprimirComprobanteError()`)
- Printed after failed DSL card payments
- Location: `checkout_page.dart:_imprimirComprobanteError()`
- Format: Error notification with error code and transaction details

**3. Service Order Receipt** (`imprimirOrdenServicio()`)
- Printed for alternative payment methods (Mostrador, Pago Móvil, Zelle)
- Location: `checkout_bottomsheet_payments.dart:_imprimirOrdenServicio()`
- Format: Simple 4-line receipt
  ```
  ================================
       ORDEN DE SERVICIO
  ================================
  ORDEN: 101234
  Cliente: V-12345678
  Fecha: 27/12/2024 14:30
  Operado por: Maria Lopez
  ```
- Parameters: ticket (last 6 digits), cliente (tipo-cedula), fechaHora (dd/MM/yyyy HH:mm), operador

**4. Test Receipt** (`imprimirTestPos()`)
- Development/testing purposes only
- Includes logo, date, sample items, test total

#### Native Implementation
All printing is handled in `MainActivity.kt`:
- `printReceipt()`: Full payment receipt (lines 202-250)
- `printOrdenServicio()`: Service order receipt (lines 341-374)
- `printerTest()`: Test receipt with logo (lines 255-336)
- `initPrinter()`: Initialize NexGO printer hardware (lines 379-384)

Uses NexGO APIProxy:
```kotlin
deviceEngine = APIProxy.getDeviceEngine(this)
printer = deviceEngine?.printer
printer?.appendPrnStr(text, fontSize, alignment, bold)
printer?.startPrint(false, OnPrintListener)
```

### Payment Methods

The application supports four payment methods:

#### 1. DSL Card Payment (Primary)
- **Location**: `checkout_page.dart`
- **Process**: Direct integration with DSL payment terminal
- **Flow**: Card transaction → Receipt printing → Firebase save → Dashboard
- **Status**: Sets order to "Preparación" (statusId=2) on success

#### 2. Pago Móvil (Alternative)
- **Location**: `checkout_bottomsheet_payments.dart`
- **Process**: Bank transfer verification via BDV API
- **Required Data**: Banco emisor, Cédula/RIF, Teléfono, Referencia
- **Validation**: Checks reference against BDV conciliation service
- **Success**: Conciliated payment → statusId=2 (Preparación)
- **Failure**: Manual review → statusId=0 (Solicitado)

#### 3. Zelle (Alternative)
- **Location**: `checkout_bottomsheet_payments.dart`
- **Process**: Manual confirmation with reference number
- **Required Data**: Referencia/Confirmación
- **Status**: Always statusId=0 (Solicitado) - pending verification
- **Receipt**: Prints ORDEN DE SERVICIO

#### 4. Mostrador / Counter (Alternative)
- **Location**: `checkout_bottomsheet_payments.dart`
- **Process**: Payment pending at counter
- **Required Data**: None (uses existing customer info)
- **Status**: statusId=0 (Solicitado), totalPaid=0
- **Receipt**: Prints ORDEN DE SERVICIO with order details
- **Flow**: Print receipt → Save to Firebase → Dashboard

#### Payment UI Flow
1. User completes order in `checkout_page.dart`
2. For DSL payment: Direct card processing in same page
3. For alternatives: Opens `CheckoutBottomsheetPayments` bottomsheet
4. User selects method → Fills required fields → Confirms
5. Payment processed → Receipt printed (if applicable) → Order saved

### Key Infrastructure Files

#### `/lib/infrastructure/functions/nexgo_funtions/`
- `nexgo_funtions.dart`: Flutter wrappers for NexGO MethodChannel
  - `DoTransaction`: Payment processing class
  - `PrinterPos`: General printing class

#### `/lib/infrastructure/models/`
- `record_response_model.dart`: DSL payment transaction response
- `settlement_response_sdk_model.dart`: End-of-day settlement response

#### `/android/app/src/main/kotlin/com/fullqueso/dslqueso/`
- `MainActivity.kt`: Native Android integration
  - MethodChannel handler for `nexgo_service`
  - DSL service binding and transaction processing
  - Printer operations via NexGO APIProxy

### Important Technical Notes

1. **Service Binding**: DSL service MUST be bound before any payment attempts
   - Call `DoTransaction().bindService()` on app initialization
   - Check `smartService != null` before transactions
   - Failure to bind shows: "El servicio DSL no está conectado. Reinicie la aplicación."

2. **Error Code Handling**:
   - Success: `result == 0`
   - All errors: `result != 0` with `errorCode` for details
   - Error receipts printed automatically for failed transactions

3. **Receipt Formatting**:
   - Ticket numbers displayed as last 6 digits only
   - Customer format: "V-12345678" (tipo-cedula)
   - Date format: "dd/MM/yyyy HH:mm"
   - Operator from: `SharedService.operatorName`

4. **Printer Margins**:
   - All receipts end with 5 line breaks (\n\n\n\n\n)
   - Ensures easy paper tear-off from thermal printer

5. **Navigation After Payment**:
   - Always navigate to `DashboardPage` after successful order save
   - Use `Navigator.pushReplacement()` to clear checkout stack

## Styling and Theme

- **Font**: Montserrat family (9 weights) loaded from local assets
- **Theme**: Material Design 3 with custom color scheme (AppColor.primary)
- **Colors**: Defined in `lib/theme/color.dart` and `lib/theme/palette.dart`
- **Splash Screen**: Red background (#FE0019) with custom logo

## Version Management

Current version: **2.5.12+17** (defined in pubspec.yaml)
- Version format: `major.minor.patch+build`
- Update version in pubspec.yaml when releasing

## Key Dependencies

**Core Flutter & Firebase**:
- `firebase_core`, `firebase_auth`, `firebase_database`, `firebase_crashlytics`
- `cloud_firestore` for NoSQL database operations

**UI & Networking**:
- `cached_network_image` for efficient image loading
- `flutter_spinkit` for loading animations
- `http` for API communication

**Utilities**:
- `shared_preferences` for local data persistence
- `intl` for internationalization and number formatting
- `timeago` for relative time display
- `package_info_plus` for app version management

**Native Android (build.gradle)**:
- `com.google.code.gson:gson` - JSON serialization for NexGO responses
- NexGO SDK libraries (oaf-apiv3, smartconnect) - Payment and printer integration

## Daily Settlement Control System

### Overview

The app implements a mandatory daily settlement (batch closure) control system to ensure operators cannot start a new sales day without closing the previous day's transactions on the POS terminal. This is critical for financial reconciliation and POS terminal management.

### Purpose

**Business Requirement**: POS terminals require end-of-day settlement (cierre de lote) to consolidate transactions and clear the terminal's batch. If an operator forgets to close the batch at the end of their shift, they must complete it before processing any new sales.

**Technical Implementation**: The system tracks the last successful settlement date and prevents checkout operations if the current day is different from the last settlement date.

### Architecture

#### Components

**1. Data Persistence** (`lib/services/shared_service.dart`)
- **Variable**: `lastSettlementDate` (String, format: "yyyy-MM-dd")
- **Storage**: SharedPreferences (persists across app restarts and device reboots)
- **Lifecycle**: Set on successful settlement, never reset on logout (intentional)
- **Location**: Lines 24, 40-47

**2. Settlement Recording** (`lib/pages/signout_page.dart`)
- **Trigger**: Successful DSL settlement transaction (`result.result == 0`)
- **Action**: Saves current date to `SharedService.lastSettlementDate`
- **Location**: Line 47
- **Code**:
  ```dart
  SharedService.lastSettlementDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  ```

**3. Settlement Verification** (`lib/pages/dashboard_page.dart`)
- **Method**: `_checkSettlementRequired()` (lines 176-258)
- **Verification Points**:
  - **InitState** (line 374): After products load, checks immediately upon dashboard entry
  - **Checkout** (line 358): Before navigation to checkout, blocks transaction if settlement pending

### How It Works

#### Settlement Date Tracking

1. **First Use**: `lastSettlementDate` is empty → No verification performed
2. **After First Settlement**: Date is saved (e.g., "2026-01-03")
3. **Same Day**: Comparisons show same day → Normal operations continue
4. **Next Day**: Comparison detects different day → Alert triggered

#### Date Comparison Logic

```dart
final lastDate = DateFormat('yyyy-MM-dd').parse(lastSettlement);
final today = DateTime.now();
final isDifferentDay = lastDate.year != today.year ||
                       lastDate.month != today.month ||
                       lastDate.day != today.day;
```

#### Blocking Dialog

When settlement is required, a **non-dismissible** dialog appears with:
- **Title**: "Cierre de Lote Pendiente" with warning icon
- **Message**: "Debe realizar el cierre de lote antes de continuar con las ventas."
- **Last Settlement Date**: Shows formatted date (dd/MM/yyyy)
- **Action**: Single button "Ir a Cierre de Lote" → Navigates to `SignoutPage`
- **Behavior**: `barrierDismissible: false` (cannot be dismissed by tapping outside)

### Verification Flow

#### Scenario 1: Normal Daily Operations
1. Day 1: Operator logs in → Sells → Closes settlement → Logs out
2. `lastSettlementDate` = "2026-01-03"
3. Day 2: Operator logs in → Dashboard loads → No alert (same day or first login of new day)
4. When attempting checkout → Verification runs → Alert blocks checkout
5. Operator forced to `SignoutPage` → Completes settlement
6. `lastSettlementDate` updates to "2026-01-04"
7. Returns to dashboard → Can now process sales

#### Scenario 2: Forgotten Settlement
1. Day 1: Operator logs in → Sells → **Forgets to close settlement** → Logs out
2. `lastSettlementDate` = "2026-01-02" (previous settlement)
3. Day 2: Operator logs in → Dashboard loads → **Alert appears immediately**
4. If alert closed accidentally → Attempting checkout → **Alert appears again**
5. Forced to complete settlement before any sales

#### Scenario 3: App Left Open Overnight
1. Day 1 (23:00): Operator working, app open
2. Midnight passes → Now Day 2
3. Operator attempts checkout → Verification detects day change
4. Alert blocks checkout → Must complete settlement

### Double Verification Strategy

**Why Two Checkpoints?**

1. **InitState Verification** (Primary)
   - **When**: After `fetchProducts()` completes
   - **Purpose**: Early warning - alerts user immediately upon dashboard entry
   - **User Impact**: Cannot ignore or miss the requirement
   - **Performance**: No impact (runs after async product loading)

2. **Checkout Verification** (Failsafe)
   - **When**: Start of `_goToCheckout()` method
   - **Purpose**: Safety barrier - ensures no sales can proceed if settlement pending
   - **User Impact**: Blocks transaction even if initial alert was somehow bypassed
   - **Performance**: Negligible (simple date string comparison)

**Benefits**:
- ✅ Redundant protection against forgotten settlements
- ✅ Handles edge cases (app backgrounded, alert dismissed, etc.)
- ✅ Minimal performance overhead (instant date comparison)

### Technical Details

#### Date Format
- **Storage**: "yyyy-MM-dd" (e.g., "2026-01-03")
- **Display**: "dd/MM/yyyy" (e.g., "03/01/2026")
- **Timezone**: Uses device local time via `DateTime.now()`

#### Error Handling
- All date parsing wrapped in `try-catch` blocks
- Parse failures logged with `debugPrint()`
- Failed verification allows operation to continue (fail-open for safety)

#### Navigation
- Alert → SignoutPage uses `Navigator.push()` (modal navigation)
- User must complete or cancel settlement to return to dashboard
- After settlement → `lastSettlementDate` updates → Verification passes

### Testing Checklist

**Manual Testing Scenarios**:

1. **First Installation**
   - [ ] Install app → Login → No alert appears
   - [ ] Complete first settlement → Date saved correctly

2. **Same Day Operations**
   - [ ] Login → Sell → Checkout works without alert
   - [ ] Multiple checkouts → No alerts

3. **Next Day Without Settlement**
   - [ ] Change device date to next day OR wait until midnight
   - [ ] Open dashboard → Alert appears immediately
   - [ ] Try checkout → Alert blocks transaction
   - [ ] Complete settlement → Alert clears

4. **App Persistence**
   - [ ] Complete settlement → Close app
   - [ ] Reopen app → No alert (same day)
   - [ ] Change date → Reopen app → Alert appears

5. **Logout Scenario**
   - [ ] Complete settlement Day 1 → Logout
   - [ ] Login Day 2 → Alert appears
   - [ ] Verify `lastSettlementDate` persisted through logout

### Code Locations Reference

| Component | File | Lines | Description |
|-----------|------|-------|-------------|
| Data model | `lib/services/shared_service.dart` | 24, 40-47 | `lastSettlementDate` variable and getters/setters |
| Settlement save | `lib/pages/signout_page.dart` | 47 | Updates date on successful settlement |
| Verification method | `lib/pages/dashboard_page.dart` | 176-258 | `_checkSettlementRequired()` logic and dialog |
| InitState check | `lib/pages/dashboard_page.dart` | 374 | First verification point |
| Checkout check | `lib/pages/dashboard_page.dart` | 346-364 | Second verification point (failsafe) |

### Future Enhancements

**Potential Improvements**:
- Add settlement reminder notifications at end of day (e.g., 22:00)
- Track settlement history for audit trail
- Admin override capability for emergency situations
- Settlement status indicator on dashboard UI
- Automatic settlement prompt after last transaction of day