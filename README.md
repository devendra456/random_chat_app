# Random Chat Application
A Flutter-based mobile application that allows users to engage in real-time, anonymous one-on-one conversations with other random users.

## Features

**Anonymous Chat Pairing**: Automatically pairs users randomly
**Real-time Messaging**: Send and receive messages instantly
**User Identity**: Generate temporary display names for chat sessions
**Simple UI**: Easy-to-use interface for starting and participating in chats
**End-to-End Encryption**: Secure conversations with no data storage

## Technologies Used

**Frontend**: Flutter
**Backend**: Firebase 
- Firebase Authentication
- Firebase Realtime Database
- Firebase Cloud Functions (optional)
- Firebase Cloud Messaging (for notifications)

## Getting Started

### Prerequisites
- Flutter SDK (^3.7.0)
- Dart SDK
- Android Studio / VS Code
- Firebase account

### Installation

1. Clone the repository
```
   git clone <repository-url>
   cd app
   ```

2. Install dependencies
```
   flutter pub get
   ```

3. Connect project to Firebase
1. Create a Firebase Project in https://console.firebase.google.com/
2. Add an Android App (in settings)
3. Download google-services.json file and place it inside android/app folder of flutter project
4. In terminal run command `flutterfire configure`
4. Run the application
```
   flutter run
   ```

## Project Structure

- `lib/main.dart` - Entry point of the application
- `lib/screens/` - UI screens (home, chat)
- `lib/services/` - Business logic and Firebase services

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
