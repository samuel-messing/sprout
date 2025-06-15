# Sprout 🌱

A Flutter app for collecting speech recordings from children as part of language development research. The app is designed to be used by parents or older children and provides a trustworthy, simple, and slightly playful experience.

## Features

- **Study Management**: View and participate in available language studies
- **Demographics Collection**: Collect participant demographic information
- **Audio Recording**: Record word pronunciations with visual feedback
- **Cloud Storage**: Secure upload to Firebase Storage with structured metadata
- **Device Tracking**: Automatic device information collection for research purposes
- **Offline-Ready**: Handles network issues gracefully with retry functionality

## Tech Stack

- **Flutter** (>=3.10.0) with null safety
- **Firebase**:
  - Firebase Auth (anonymous authentication)
  - Cloud Firestore (metadata storage)
  - Firebase Storage (audio file storage)
- **Audio Recording**: `record` package
- **Device Info**: `device_info_plus` package

## Project Structure

```
lib/
├── main.dart                 # App entry point with Firebase initialization
├── models/                   # Data models
│   ├── study.dart           # Study model
│   ├── user_demographics.dart # User demographics model
│   └── recording_response.dart # Recording metadata model
├── services/                 # Business logic services
│   ├── firebase_service.dart  # Firebase operations
│   ├── audio_service.dart     # Audio recording
│   └── device_info_service.dart # Device information
├── screens/                  # UI screens
│   ├── study_list_screen.dart      # Study selection
│   ├── demographics_screen.dart    # Demographics form
│   ├── word_prompt_screen.dart     # Recording interface
│   └── thank_you_screen.dart       # Completion screen
└── widgets/                  # Reusable UI components
    ├── loading_widget.dart
    ├── error_widget.dart
    ├── record_button.dart
    └── timer_widget.dart

test/                        # Unit and widget tests
assets/                      # Static assets
android/                     # Android-specific files
ios/                         # iOS-specific files
```

## Firebase Schema

### Collections

#### `studies`

```json
{
  "title": "Animals Word Study",
  "description": "Say 10 animal words for research",
  "wordList": ["dog", "cat", "elephant"],
  "imageUrls": {
    "dog": "https://example.com/dog.jpg",
    "cat": "https://example.com/cat.jpg"
  },
  "active": true,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

#### `users`

```json
{
  "demographics": {
    "age": 5,
    "gender": "female",
    "languages": ["English", "Spanish"]
  },
  "createdAt": "2024-01-15T10:30:00Z"
}
```

#### `responses`

```json
{
  "userId": "9e8x4h",
  "studyId": "study_abc",
  "word": "dog",
  "timestamp": "2024-01-15T14:12:03Z",
  "filePath": "recordings/study_abc/9e8x4h/dog_20240115T141203Z.wav",
  "duration": 4.8,
  "deviceInfo": {
    "platform": "ios",
    "osVersion": "17.4.1",
    "model": "iPhone 14",
    "manufacturer": "Apple"
  }
}
```

## Cloud Storage Structure

Files are uploaded with this naming convention:

```
gs://[bucket]/recordings/{studyId}/{userId}/{word}_{timestamp}.wav
```

Example:

```
gs://sprout-recordings/recordings/study_abc/9e8x4h/dog_20240115T141203Z.wav
```

## Setup Instructions

### Prerequisites

- Flutter SDK (>=3.10.0)
- Firebase account and project
- Android Studio / Xcode for mobile development

### Firebase Setup

1. **Create Firebase Project**

   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Authentication, Firestore, and Storage

2. **Configure Authentication**

   - Enable Anonymous authentication in Firebase Console
   - Go to Authentication > Sign-in method > Anonymous > Enable

3. **Configure Firestore**

   - Create Firestore database in production mode
   - Set up security rules (see Security Rules section)

4. **Configure Storage**

   - Create Storage bucket
   - Set up security rules for file uploads

5. **Add Firebase Configuration Files**
   - **Android**: Download `google-services.json` to `android/app/`
   - **iOS**: Download `GoogleService-Info.plist` to `ios/Runner/`

### Local Development

1. **Clone Repository**

   ```bash
   git clone <repository-url>
   cd sprout
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate Mock Files** (for testing)

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

### Testing

Run all tests:

```bash
flutter test
```

Run specific test files:

```bash
flutter test test/services/firebase_service_test.dart
flutter test test/widgets/study_list_screen_test.dart
```

Generate test coverage:

```bash
flutter test --coverage
```

## Firebase Security Rules

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to active studies
    match /studies/{studyId} {
      allow read: if resource.data.active == true;
    }

    // Allow users to read/write their own demographics
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Allow authenticated users to create responses
    match /responses/{responseId} {
      allow create: if request.auth != null &&
                   request.auth.uid == resource.data.userId;
    }
  }
}
```

### Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /recordings/{studyId}/{userId}/{filename} {
      allow create: if request.auth != null &&
                   request.auth.uid == userId &&
                   request.resource.size < 10 * 1024 * 1024; // 10MB limit
    }
  }
}
```

## Adding Sample Data

To test the app, add sample studies to Firestore:

```javascript
// In Firebase console, add to 'studies' collection:
{
  title: "Animal Sounds",
  description: "Help us learn by saying these animal words!",
  wordList: ["dog", "cat", "bird", "cow", "sheep"],
  imageUrls: {
    dog: "https://images.unsplash.com/photo-1552053831-71594a27632d?w=400",
    cat: "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400",
    bird: "https://images.unsplash.com/photo-1444464666168-49d633b86797?w=400",
    cow: "https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400",
    sheep: "https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400"
  },
  active: true,
  createdAt: new Date()
}
```

## Permissions

### Android

Required permissions in `android/app/src/main/AndroidManifest.xml`:

- `RECORD_AUDIO` - For audio recording
- `INTERNET` - For Firebase communication
- `WRITE_EXTERNAL_STORAGE` - For temporary file storage

### iOS

Required permissions in `ios/Runner/Info.plist`:

- `NSMicrophoneUsageDescription` - For microphone access

## Architecture Notes

- **Clean Architecture**: Services handle business logic, widgets handle UI
- **Error Handling**: Comprehensive error states with retry mechanisms
- **State Management**: Uses built-in Flutter state management with StreamBuilder
- **Offline Support**: Graceful handling of network issues
- **Performance**: Efficient image loading and caching

## Contributing

1. Follow Flutter style guidelines
2. Write tests for new features
3. Update documentation for API changes
4. Use meaningful commit messages
5. Test on both Android and iOS before submitting

## Privacy & Ethics

This app is designed for research purposes with the following considerations:

- Anonymous authentication protects user identity
- Minimal demographic data collection
- Secure cloud storage with access controls
- Clear privacy notices in the UI
- Parental consent mechanisms can be added as needed

## Troubleshooting

### Common Issues

1. **Firebase configuration missing**

   - Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are properly added

2. **Microphone permissions denied**

   - Check device settings and app permissions
   - Ensure proper permission declarations in manifests

3. **Network connectivity issues**

   - App handles offline scenarios gracefully
   - Check Firebase project configuration and rules

4. **Build errors**
   - Run `flutter clean && flutter pub get`
   - Check Flutter and dependency versions

## License

[Specify your license here]

## Support

For technical support or questions about the research study, please contact [your contact information].
