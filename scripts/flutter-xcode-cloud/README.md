# Xcode Cloud CI/CD для Flutter

Скрипт `ci_post_clone.sh` автоматизирует процесс сборки Flutter приложения в Xcode Cloud:
- Увеличивает номер сборки
- Создает release notes из коммитов
- Пушит изменения обратно в репозиторий

## Быстрая настройка

1. Создайте SSH ключ:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
# Сохраните в ~/.ssh/id_ed25519
```

2. Добавьте публичный ключ в GitHub:
- Скопируйте содержимое `~/.ssh/id_ed25519.pub`
- GitHub -> Settings -> SSH Keys -> New SSH key

3. Подготовьте приватный ключ для Xcode Cloud:
```bash
base64 -i ~/.ssh/id_ed25519
# Скопируйте весь output
```

4. Добавьте скрипт в проект:
```bash
# В корне iOS проекта
mkdir -p ci_scripts
cp ci_post_clone.sh ci_scripts/
chmod +x ci_scripts/ci_post_clone.sh
git add ci_scripts/ci_post_clone.sh
git commit -m "chore: add xcode cloud script"
```

5. Настройте Xcode Cloud:
- Workflow -> Post-Clone -> New Script
- Path: `ci_scripts/ci_post_clone.sh`
- Environment Variables:
  - Name: `SSH_KEY`
  - Value: <output из шага 3>

6. Настройте Git для коммитов:
```bash
git config --global user.email "your_email@example.com"
git config --global user.name "Your Name"
```

## Теги для коммитов

- `[build]` - Отмечает коммит сборки
- `[notes skip]` - Исключает коммит из release notes

Примеры:
```bash
git commit -m "feat: добавлена новая функция" # сборка
git commit -m "chore: обновлены зависимости [notes skip] [ci skip]" # не включать в release notes и не запускать CI
```

## Кастомизация

1. Release Notes:
- Измените формат в функции `generate_release_notes()`
- Настройте часовой пояс (сейчас GMT+3)
- Измените количество отображаемых коммитов

2. Git-коммиты:
- Измените формат коммита в строке:
  ```bash
  git commit -m "ci(build): $new_build_number [build] [notes skip] [ci skip]"
  ```

## Важно

- Скрипт должен быть исполняемым (`chmod +x`)
- SSH ключ в Xcode Cloud должен быть в формате base64
- Проверьте права доступа к репозиторию
- В GitHub должен быть добавлен публичный SSH ключ
