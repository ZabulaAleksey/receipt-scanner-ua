# Receipt Scanner UA mobile shell

Flutter shell с fixture-driven UX и R04/R05 local-first slices: structured SQLite persistence и single photo-library image intake. Camera capture, preprocessing, OCR, backend, account, billing и sync ещё не реализованы.

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

Scan сохраняет accepted fixture flow и добавляет отдельный путь `photo library → bounded local image draft → Preview`. R05 не создаёт receipt автоматически и не запускает OCR; raw image не добавляется в SQLite payload.

## Проверки

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --no-pub
flutter test --no-pub test
flutter test --no-pub integration_test/offline_quick_flow_test.dart -d windows
flutter test --no-pub integration_test/local_image_intake_flow_test.dart -d windows
flutter build windows --release --no-pub
```

Product E2E остаётся `BLOCKED_BY_BACKEND_RECEIPT_SCANNER`: Windows integration test подтверждает только offline Flutter flow.
