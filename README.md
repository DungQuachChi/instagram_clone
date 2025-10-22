# Instagram Clone

A Flutter-based Instagram clone application with Firebase integration.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) (for iOS development)
- A code editor ([VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio))

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/DungQuachChi/instagram_clone.git
cd instagram_clone
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Install Cloud Functions Dependencies

```bash
cd functions
npm install
cd ..
```

### 4. Firebase Configuration

This project uses Firebase. Make sure you have:
- Created a Firebase project at [Firebase Console](https://console.firebase.google.com/)
- Logged into Firebase CLI:
  ```bash
  firebase login
  ```
- Added your `google-services.json` (for Android) to `android/app/`
- Added your `GoogleService-Info.plist` (for iOS) to `ios/Runner/`

## Running the Application
```bash
flutter run -d chrome
```

## Common Commands

### Flutter Commands
```bash
# Check for issues
flutter doctor

# Clean build files
flutter clean

# Rebuild dependencies
flutter pub get

# Run tests
flutter test

# Build APK (Android)
flutter build apk

# Build iOS (macOS only)
flutter build ios
```

### Firebase Commands
```bash
# Login to Firebase
firebase login

# Initialize Firebase (if needed)
firebase init

# Start emulators
firebase emulators:start

# Deploy everything
firebase deploy

# Deploy specific service
firebase deploy --only functions
firebase deploy --only hosting
```

## Project Structure

```
instagram_clone/
├── lib/           # Main application code
├── android/       # Android-specific files
├── ios/           # iOS-specific files
├── web/           # Web-specific files
└── test/          # Test files
```

## Troubleshooting

### Flutter Dependencies Issues
```bash
flutter clean
flutter pub get
```

### Build Issues
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter run
```

### Cloud Functions Issues
```bash
cd functions
rm -rf node_modules
npm install
cd ..
```

### Firebase Authentication Issues
Make sure you're logged in:
```bash
firebase login
firebase projects:list
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Documentation](https://dart.dev/guides)

## License

This project is for educational purposes.