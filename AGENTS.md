# Repository Guidelines

## Project Structure & Module Organization
- Source code lives in `lib/` and follows a clean architecture split:
  - `lib/app`, `lib/core`, `lib/data`, `lib/domain`, `lib/presentation`, `lib/services`.
- UI screens/components: `lib/presentation/screens`, `lib/presentation/widgets`.
- Services and utilities: `lib/core/services`, `lib/core/utils`.
- Models go in `lib/data/models` and generate `*.g.dart` files (do not edit generated files).
- Tests mirror `lib/` under `test/` using the same folder structure.
- Assets are under `assets/images`, `assets/icons`, `assets/animations` (declared in `pubspec.yaml`).

## Build, Test, and Development Commands
- Install deps: `flutter pub get`
- Generate code (models/adapters): `flutter pub run build_runner build --delete-conflicting-outputs`
- Analyze lint/errors (uses `analysis_options.yaml`): `flutter analyze`
- Format code: `dart format .`
- Run locally (web): `flutter run -d chrome` → http://localhost:8080
- Run on Android: `flutter run`
- Tests (with coverage): `flutter test --coverage`
- Production builds: `flutter build apk --release` or `flutter build appbundle --release`

## Coding Style & Naming Conventions
- Lints: Inherit from `flutter_lints` (`analysis_options.yaml`). Use 2-space indentation.
- Files: `snake_case.dart` (e.g., `lib/presentation/screens/lock_screen/lock_screen.dart`).
- Types: `UpperCamelCase`; members/functions: `lowerCamelCase`.
- Keep widgets small and composable; one primary widget per file.
- Avoid printing secrets; prefer `logger` in `lib/core/utils/logger.dart` and guard verbose logs for debug.

## Testing Guidelines
- Framework: `flutter_test`. Place tests in `test/` with names like `*_test.dart` mirroring `lib/` paths.
- Run `flutter pub run build_runner build` before tests if models changed.
- Aim for high coverage on providers/services (auth, app lock, storage, encryption).
- Example: widget tests should `pumpWidget` minimal trees and assert UI/state changes.

## Commit & Pull Request Guidelines
- Use Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`.
  - Example: `feat: add biometric fallback on web`.
- PRs must include: clear description, linked issue(s), screenshots for UI changes, test updates, and a note on any schema/model changes.
- PRs should pass: `flutter analyze`, `dart format .`, and `flutter test` locally.

## Security & Configuration Tips
- Do not commit secrets/keys. Encryption keys live only in secure storage (`lib/core/services/encryption_service.dart`).
- Avoid logging sensitive data. Keep Android signing configs outside the repo; use release keystores in `android/` via local gradle properties.
