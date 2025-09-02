# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## About Sprout

Sprout is a Flutter app for collecting speech recordings from children for language development research. It provides a trustworthy, simple, and playful interface for participants to record word pronunciations while securely storing data in Firebase.

## Development Commands

### Essential Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run the app in debug mode
flutter run

# Run on specific device
flutter run -d <device-id>

# Build for release
flutter build apk
flutter build ios
flutter build web

# Clean build artifacts
flutter clean

# Update dependencies
flutter pub upgrade
```

### Testing Commands
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/firebase_service_test.dart

# Run tests with coverage
flutter test --coverage

# Generate coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
```

### Code Quality Commands
```bash
# Run static analysis
flutter analyze

# Format all Dart code
flutter format .

# Format specific files
flutter format lib/main.dart

# Check formatting without applying changes
flutter format --dry-run .
```

### Firebase Commands
```bash
# Start Firebase emulators (if configured)
firebase emulators:start

# Deploy Firebase rules and indexes
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
firebase deploy --only firestore:indexes
```

### Build Runner Commands
```bash
# Generate mock files for testing
flutter packages pub run build_runner build

# Watch for changes and regenerate
flutter packages pub run build_runner watch

# Clean generated files
flutter packages pub run build_runner clean
```

## Architecture Overview

### Application Structure

Sprout follows a clean architecture pattern with clear separation of concerns:

- **Models** (`lib/models/`): Data models that represent the core entities (Study, UserDemographics, RecordingResponse)
- **Services** (`lib/services/`): Business logic layer handling Firebase operations, audio recording, and device info
- **Screens** (`lib/screens/`): Full-page UI components representing different app states
- **Widgets** (`lib/widgets/`): Reusable UI components

### Key Architectural Patterns

#### Service Layer Pattern
The app uses a singleton service pattern for Firebase operations:
- `FirebaseService.instance` provides centralized access to all Firebase operations
- Services are stateless and focus on business logic
- Error handling is consistently implemented across all service methods

#### State Management
- Uses Flutter's built-in state management with `StreamBuilder` for real-time data
- Firebase Firestore streams provide reactive data updates
- No external state management library (like Provider or Bloc) is used

#### Screen Flow Architecture
The app follows a linear flow:
1. `StudyListScreen` → Display available studies
2. `DemographicsScreen` → Collect user information
3. `WordPromptScreen` → Record pronunciations for each word
4. `ThankYouScreen` → Completion confirmation

### Firebase Integration Architecture

#### Authentication
- Uses Firebase Anonymous Auth for privacy-focused user identification
- Users are automatically signed in on app launch
- No personal identifiers collected

#### Data Storage
- **Firestore**: Stores studies, user demographics, and recording metadata
- **Storage**: Stores actual audio files with structured naming convention
- **Security Rules**: Implemented for both Firestore and Storage (documented in README)

#### File Naming Convention
Audio files follow a structured pattern:
```
recordings/{studyId}/{userId}/{word}_{timestamp}.wav
```

### Error Handling Strategy

The app implements comprehensive error handling:
- Service methods throw descriptive exceptions
- UI shows error states with retry functionality
- Network issues are handled gracefully with offline-ready design
- All Firebase operations are wrapped in try-catch blocks

## Development Patterns

### Widget Structure
- Use `const` constructors wherever possible for performance
- Separate complex widgets into their own classes
- Follow Material Design guidelines with consistent theming

### Model Patterns
- All models include both `fromFirestore()` and `toFirestore()` methods
- Use proper null safety throughout
- Include factory constructors for data deserialization

### Service Patterns
- Services are singletons accessed via `instance` getter
- All async operations return `Future` or `Stream`
- Consistent error handling with descriptive exception messages

### Testing Approach
- Use `mockito` for mocking Firebase services
- Widget tests focus on UI behavior
- Unit tests cover service logic and model serialization

## Firebase Configuration

### Required Setup
1. Firebase project with Authentication, Firestore, and Storage enabled
2. Anonymous authentication enabled
3. Platform-specific configuration files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### Security Rules
Firebase security rules are referenced in README.md and should be deployed separately. The app assumes:
- Anonymous users can read active studies
- Users can only access their own demographics and responses
- File uploads are limited to authenticated users with size restrictions

### Emulator Support
The app supports Firebase emulators for local development (see `firebase.json` configuration).

## Key Dependencies

### Core Flutter Dependencies
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`: Firebase integration
- `record`: Audio recording functionality
- `device_info_plus`: Device information collection for research
- `path_provider`: File system access for temporary audio storage

### Development Dependencies
- `flutter_lints`: Dart linting rules
- `mockito`: Mocking framework for testing
- `build_runner`: Code generation for mocks

## Development Notes

### Audio Recording Flow
1. User presses record button in `WordPromptScreen`
2. `AudioService` starts recording and saves to temporary file
3. Recording stops and file is uploaded via `FirebaseService`
4. Metadata is saved to Firestore with device info and timestamps

### Data Privacy Considerations
- App uses anonymous authentication to protect user identity
- Minimal demographic data collection
- All data stored securely in Firebase with proper access controls
- Recording files are stored with non-identifiable naming conventions

### Platform Considerations
- Android requires `RECORD_AUDIO` permission
- iOS requires microphone usage description in Info.plist
- Web platform is supported but may have audio recording limitations

### Performance Considerations
- Audio files are uploaded immediately after recording
- Large image assets should be optimized and cached
- Use `StreamBuilder` efficiently to avoid unnecessary rebuilds
- Implement proper loading states for network operations
