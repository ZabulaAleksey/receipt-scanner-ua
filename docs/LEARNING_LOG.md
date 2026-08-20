# Learning Log

## 2026-08-11 — Разбиение спецификации Receipt Scanner UA

### Задача

Перенести содержимое монолитного Markdown-файла в проект и уменьшить постоянную нагрузку на контекст.

### Что исследовали

Проверили размер и заголовки исходного файла, правила рабочей области, Git-состояние и существующие файлы проекта.

### Основные команды

`git status --short --branch` — проверка ветки и незавершённых изменений перед записью.

### Как была устроена проблема

Один файл объединял архитектуру, правила контекста, шаблоны документов и 24 независимых stage-промпта. Для локальной задачи это вынуждало загружать лишние разделы.

### Что изменили

Разделы сгруппированы по назначению, а каждый stage-промпт вынесен в отдельный файл. Добавлены индекс и минимальные документы состояния.

### Почему выбран такой подход

Мелкие тематические файлы позволяют загружать только текущую архитектурную область и один этап, сохраняя исходный текст и навигацию.

### Что пошло не так

Корневой `AGENTS.md` уже существовал, хотя был пустым. Чтобы не перезаписывать существующий файл без согласования, предложенное содержимое сохранено как `AGENTS.proposed.md`. Новые русские подписи при первом запуске попали под ANSI-декодирование PowerShell; это обнаружила UTF-8-проверка, после чего конкретные созданные файлы были записаны точными UTF-8-данными.

### Проверки

Проверяются покрытие всех 57 разделов, отсутствие перезаписи, UTF-8-кодировка, Markdown-ссылки и парность code fences.

### Как повторить вручную

1. Получить список Markdown-заголовков.
2. Разделить разделы по назначению.
3. Проверить существующие целевые файлы.
4. Создать индекс со ссылками.
5. Сверить число исходных и распределённых разделов.
6. Открыть результат как UTF-8 и проверить кириллицу.

### Что стоит изучить

Markdown-навигацию, выборочную загрузку контекста, Git-ветки для документационных изменений и проверку UTF-8.

## 2026-08-20 — R03 Flutter fixture-driven mobile shell

### Что и зачем изменено

- Выбран Flutter для быстрого UX-first prototype Android/iOS shell и зафиксирован ADR-004.
- Создан offline shell на synthetic fixtures, чтобы проверить навигацию, состояния и accessibility до real camera/OCR/backend.

### Ключевой поток данных / управления

```text
synthetic fixtures
→ FixtureScenarioPort
→ use cases / in-memory adapters
→ AppController
→ typed Flutter routes
→ result / review / history UI
```

### Команды и проверки

```powershell
cd mobile
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --no-pub
flutter test --no-pub test
flutter test --no-pub integration_test/offline_quick_flow_test.dart -d windows
flutter build windows --release --no-pub
```

### Решения и trade-offs

- Flutter выбран для R03 testing/golden workflow и общей UI codebase; KMP/Compose остаётся вариантом пересмотра перед дорогими native integrations.
- Windows runner даёт compile/visual evidence, но не заменяет Android/iOS validation.
- In-memory adapters намеренно не создают преждевременный persistence contract.

### Проблемы и способы исправления

- В исходном golden не отображались кириллица и Material Icons; bundled Roboto и test `FontLoader` сделали baseline детерминированным.
- Диагностические state controls сначала попали в production UI; states переведены под прямое управление controller в tests.

### Как повторить самостоятельно

1. Установить Flutter и проверить `flutter doctor -v`.
2. Из `mobile/` выполнить `flutter pub get` и команды проверки выше.
3. Запустить shell через `flutter run -d windows` либо доступный Android/iOS device.
4. Сравнить `mobile/test/goldens/home.png` с концептами в `docs/design-concepts/`.
5. Перед real persistence/camera/OCR создать отдельный Functional MVP SPEC и acceptance criteria.
