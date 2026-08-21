# Receipt Scanner UA mobile shell

Fixture-driven Flutter prototype для проверки UX MVP без real camera, OCR, database, backend, account, billing или sync.

## Targets

- Android и iOS — product targets.
- Windows — только локальный validation runner.
- PWA/WebView не поддерживаются как mobile target.

Проверенная локальная версия: Flutter `3.47.1`, Dart `3.13.1`. Android требует установленный Android SDK; iOS — macOS/Xcode.

## Запуск

```powershell
flutter pub get
flutter run -d windows
```

Начальный экран использует только bundled synthetic fixtures. Основной путь: `Home → Scan Simulation → Preview → Processing → Result → Save`.

## Проверки

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --no-pub
flutter test --no-pub test
flutter test --no-pub integration_test/offline_quick_flow_test.dart -d windows
flutter build windows --release --no-pub
```

Product E2E остаётся `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`: Windows integration test подтверждает только offline Flutter flow.
