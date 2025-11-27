# Bookstore App — Developer Guide

## Table of Contents
1. Project Overview
2. Setup Instructions
3. Folder / File Structure
4. Coding Standards / Guidelines
5. Architecture Overview
6. Adding Features
7. Testing
8. Version Control Guidelines
9. Troubleshooting for Developers
10. References / Resources

## 1. Project Overview
The Bookstore app is a Flutter-based application that allows users to browse, search, purchase, and manage books. Admin users can manage inventory and orders.
Technologies Used: Flutter, Dart, SQLite (local database), and standard Flutter packages.

## 2. Setup Instructions
1. Install Flutter & Dart SDK (https://flutter.dev/docs/get-started/install)
2. Clone the repository:
   git clone https://github.com/AngelGiftFrancis/bookstore.git
   cd bookstore
3. Install dependencies: flutter pub get
4. Run the app: flutter run
Optional builds: flutter build apk (Android), flutter build ios (iOS), flutter build web (Web)

## 3. Folder / File Structure
- lib/ ? Main source code
  - main.dart ? App entry point
  - screens/ ? UI screens
  - widgets/ ? Reusable widgets
  - models/ ? Data models
  - services/ ? Business logic & database interactions
- android/, ios/, web/ ? Platform-specific files
- test/ ? Unit & widget tests
- pubspec.yaml ? Dependencies & metadata

## 4. Coding Standards / Guidelines
- File Naming: snake_case.dart
- Class Naming: PascalCase
- Widgets: Stateless widgets end with 'Widget'
- Comments: Use /// for documentation
- Formatting: dart format .

## 5. Architecture Overview
- Uses Provider / State Management
- Screens handle UI, Services handle logic & DB
- SQLite used as local database

## 6. Adding Features
1. Create new screen in lib/screens/
2. Add routing in main.dart or app_router.dart
3. Create models in lib/models/
4. Add logic in lib/services/
5. Test locally: flutter run

## 7. Testing
- Unit tests: flutter test test/unit
- Widget tests: flutter test test/widget

## 8. Version Control Guidelines
- Branches: main (production), dev (development), feature/xyz (new features)
- Commit messages: [feature/fix]: Short description
- Pull requests: Merge only to dev first, then main

## 9. Troubleshooting for Developers
| Problem | Solution |
|---------|---------|
| App fails to run | Ensure Flutter & Dart SDK installed; run flutter pub get |
| Hot reload not working | Restart app |
| Database not updating | Check SQLite service implementation |
| Dependencies issues | Run flutter pub upgrade |

## 10. References / Resources
- Flutter Docs: https://flutter.dev/docs
- Dart Docs: https://dart.dev/guides
- Packages: check pubspec.yaml
- GitHub repo: https://github.com/AngelGiftFrancis/bookstore
