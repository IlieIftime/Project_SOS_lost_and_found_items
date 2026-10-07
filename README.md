# SOS Lost and Found

A Flutter mobile application that allows users to report lost or found objects, browse items reported by other users, and locate them on an interactive map.

Developed as a 3rd-year Bachelor's degree project in Mobile Programming.

## Overview

The application connects people who have lost or found objects. Regular users can report items with a photo and description, browse approved listings, and view locations on a map. Administrators moderate content by validating or removing reported items before they become publicly visible.

## Features

### Regular Users

- User registration and login
- Report lost/found items with photo and description
- Browse the list of approved items
- Filter items by category (Accessories, Keys, Documents, Electronics, Others)
- View item locations on an interactive map

### Administrators

- Dedicated admin dashboard
- Review and validate pending items
- Remove inappropriate items
- View all items (approved and pending)

## Tech Stack

- **Framework:** Flutter (3.9.2+)
- **Language:** Dart
- **Maps:** google_maps_flutter
- **Images:** image_picker
- **HTTP:** http (prepared for a real API integration)

## Project Structure

```javascript
lib/
├── main.dart                          # Entry point and app theme
├── api/                               # API integrations
├── models/                            # Data models
│   ├── user_model.dart
│   └── item_model.dart
├── screens/                           # Application screens
│   ├── login_screen.dart
│   ├── registration_screen.dart
│   ├── homepage_screen.dart
│   ├── report_form_screen.dart
│   ├── map_screen.dart
│   └── admin/
│       └── admin_dashboard_screen.dart
├── services/                          # Business logic
│   ├── auth_service.dart
│   └── item_service.dart
├── utils/                             # Utilities
│   ├── colors.dart
│   └── styles.dart
└── widgets/                           # Reusable widgets
    ├── custom_button.dart
    └── custom_textfield.dart
```

## Architecture

The application follows a simple layered architecture, separating concerns across three layers:

- **Presentation Layer** (`screens/`, `widgets/`): UI rendering, user interaction, and feedback
- **Business Logic Layer** (`services/`): authentication state and item CRUD operations, implemented as singletons acting as mock repositories
- **Data Layer** (`models/`): data structures with JSON serialization

### Key Patterns

- **Singleton:** `AuthService` and `ItemService` ensure a single shared instance across screens
- **Repository (simplified):** services abstract the data source, making it straightforward to migrate to Firebase or a REST API
- **Local state:** managed with `StatefulWidget`, avoiding unnecessary complexity for a project of this scope

### Data Flow

1. User submits a report through the UI
2. `ItemService.reportItem()` creates an item with status `pending`
3. The item is not publicly visible until an admin validates it
4. Once validated, the item appears on the homepage and map for all users

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Android Studio or VS Code
- Android/iOS emulator or a physical device

### Installation

```bash
git clone <repository-url>
cd projeto_prog_mob
flutter pub get
flutter run
```

### Google Maps Setup (Optional)

The app works without map configuration, but to enable the map screen:

1. Obtain an API key from the [Google Cloud Console](https://console.cloud.google.com/) and enable the Maps SDK for Android/iOS
2. Android: replace `YOUR_API_KEY_HERE` in `android/app/src/main/AndroidManifest.xml`
3. iOS: add the key in `ios/Runner/AppDelegate.swift` via `GMSServices.provideAPIKey("YOUR_API_KEY")` and run `pod install`

### Test Credentials

| Role | Email | Password |
| --- | --- | --- |
| Admin | admin@sos.com | admin123 |
| User | user@sos.com | user123 |

### Testing Flow

1. Log in as a regular user
2. Browse approved items on the homepage
3. Report a new item (it remains pending)
4. Log out and log in as admin
5. Validate the pending item in the dashboard
6. Log back in as user and confirm the item is now visible

## Design

Built with Material Design and a custom color scheme:

- Primary: Blue `#2196F3`
- Secondary: Light Blue `#03A9F4`
- Accent: Orange `#FF5722`
- Success: Green `#4CAF50`
- Error: Red `#F44336`

## Development Notes

- The application currently uses in-memory mock data; data resets on app restart
- To persist data in production, integrate with Firebase or a REST API
- Location is simulated; use a geolocation plugin (e.g., Geolocator) for real positioning
- Images are picked but not persisted; add Firebase Storage for production

### Useful Commands

```bash
flutter analyze          # Static analysis
flutter test             # Run tests
flutter run -v           # Run with verbose logging
flutter clean            # Clean build artifacts
flutter build apk --release   # Build release APK
```

## Future Improvements

- Firebase Authentication integration
- Data persistence with Cloud Firestore
- Real image upload with Firebase Storage
- Real-time geolocation
- Push notifications
- In-app chat between users
- Lost/found matching system
- Recovery history tracking

## License

This project was developed for educational purposes.
