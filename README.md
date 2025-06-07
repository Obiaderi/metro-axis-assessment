# Metro Axis - Delivery Management System

[![Flutter Version](https://img.shields.io/badge/Flutter-3.6.1+-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.6.1+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-Private-red.svg)](LICENSE)

A comprehensive Flutter-based delivery management application designed for logistics and delivery services. Metro Axis provides real-time tracking, authentication, and delivery management capabilities with an intuitive mobile interface.

## 📱 Features

- **Authentication System**: Phone number-based OTP verification
- **Delivery Management**: View, filter, and manage delivery orders
- **Real-time Maps**: Interactive maps with Mapbox integration
- **Camera Integration**: Capture delivery proof photos
- **Location Services**: GPS tracking and geocoding
- **Responsive UI**: Adaptive design for different screen sizes
- **State Management**: Robust state management with Riverpod
- **Offline Support**: Local data persistence with SharedPreferences

## 🏗️ Architecture

The app follows a clean architecture pattern with:

- **Models**: Data models with Freezed for immutability
- **Providers**: State management with Flutter Riverpod
- **Screens**: UI screens for different app features
- **Services**: Business logic and external API integrations
- **Utils**: Constants, themes, and utility functions
- **Widgets**: Reusable UI components

## 📋 Prerequisites

Before setting up the project, ensure you have the following installed:

### Required Software

- **Flutter SDK**: Version 3.6.1 or higher
- **Dart SDK**: Version 3.6.1 or higher (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Xcode** (for iOS development on macOS)
- **Git** for version control

### Platform Requirements

- **Android**: API level 21 (Android 5.0) or higher
- **iOS**: iOS 12.0 or higher
- **macOS**: macOS 10.14 or higher (for iOS development)

### External Services

- **Mapbox Account**: Required for map functionality
  - Sign up at [Mapbox](https://www.mapbox.com/)
  - Obtain a public access token

## 🚀 Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd metro_axis
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Generate Code Files

The project uses code generation for models and JSON serialization:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 4. Configure Environment Variables

Create a `.env` file in the project root and add your Mapbox access token:

```env
MAPBOX_ACCESS_TOKEN=your_mapbox_access_token_here
```

### Feature Enhancements

- Push notifications for delivery updates
- In-app notification system
- Email/SMS integration for customers
