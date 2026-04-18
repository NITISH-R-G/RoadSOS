# Development Guide

## Prerequisites
- Flutter SDK ^3.11.0
- Dart SDK ^3.0.0
- `melos` (if we move to a monorepo structure later)

## Environment Setup
1. Clone the repository.
2. Run `./scripts/bootstrap.sh` to install dependencies and set up pre-commit hooks.
3. Request `.env` access from a Staff Engineer and place it in the root directory.

## Running the App
```bash
flutter run
```

## Running Tests
```bash
flutter test --coverage
```

## Code Generation
We use `build_runner` for some code generation (if Freezed/JsonSerializable is added).
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
