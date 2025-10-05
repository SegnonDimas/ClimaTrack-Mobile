# Copilot Instructions for galactic_heroes

## Project Overview
- **galactic_heroes** is a Flutter application scaffolded with default structure and conventions. It targets mobile (Android/iOS), desktop (macOS, Linux, Windows), and web platforms.
- The main entry point is `lib/main.dart`, which currently implements a simple counter app. All navigation and app logic should be rooted from this file.
- UI code is organized under `lib/views/` with subfolders for `models_ui` and `pages`. These are intended for modular UI components and screens, though currently only `pages/lunch.dart` exists and is empty.

## Key Workflows
- **Build & Run:**
  - Use `flutter run` to launch the app on your target device/emulator.
  - For web: `flutter run -d chrome` or build with `flutter build web`.
  - For desktop: `flutter run -d macos`, `-d linux`, or `-d windows` as appropriate.
- **Testing:**
  - Widget tests are in `test/widget_test.dart`. Run all tests with `flutter test`.
- **Hot Reload/Restart:**
  - Use hot reload (`r` in terminal or IDE button) for UI changes. Hot restart resets app state.

## Conventions & Patterns
- **Linting:**
  - Uses `flutter_lints` (see `analysis_options.yaml`). Follow recommended Dart/Flutter style.
- **Dependencies:**
  - Managed in `pubspec.yaml`. Use `flutter pub add <package>` for new dependencies.
- **Assets:**
  - Place images/fonts in `assets/` (add to `pubspec.yaml` under `flutter/assets`).
  - Web icons and manifest are in `web/`.
  - iOS launch images in `ios/Runner/Assets.xcassets/LaunchImage.imageset/`.
- **Platform Integration:**
  - Android: `android/app/src/main/AndroidManifest.xml` for config.
  - iOS: `ios/Runner/Info.plist` and Xcode workspace for config.
  - Web: `web/manifest.json` and icons.

## External Resources
- Relies on standard Flutter/Dart SDK and `cupertino_icons`.
- No custom backend or API integration is present yet.

## Example Patterns
- **Stateful Widgets:** See `MyHomePage` in `main.dart` for state management using `setState`.
- **Widget Testing:** See `test/widget_test.dart` for interaction and verification patterns.

## Recommendations for AI Agents
- When adding new screens, place them in `lib/views/pages/` and update navigation in `main.dart`.
- Follow lint rules and use hot reload for rapid UI iteration.
- Reference platform-specific files for integration (see above).
- Keep assets organized and update `pubspec.yaml` when adding new ones.

---
If any conventions or workflows are unclear, please ask for clarification or examples from the maintainers.
