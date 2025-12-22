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