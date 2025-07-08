#!/bin/bash

# Путь к репозиторию
REPO_DIR=~/dotfiles
LOG_FILE="$REPO_DIR/biweekly_update.log"

# Переходим в директорию репозитория
cd $REPO_DIR || exit

# Исключаем лог-файл из индекса (если ещё не добавлен в .gitignore)
git update-index --assume-unchanged "$LOG_FILE"

# Запускаем обновление Brewfile
~/dotfiles/scripts/update_brewfile.sh

# Запускаем обновление списка расширений
~/dotfiles/scripts/update_extensions.sh

# Проверяем изменения без учёта лог-файла
if git status --porcelain | grep -v "$LOG_FILE" | grep -q "."; then
    echo "$(date): Обнаружены изменения. Начинаем обработку..." >> "$LOG_FILE"

    # Цикл по изменённым файлам или папкам
    git status --porcelain | grep -v "$LOG_FILE" | while read -r status file; do
        case "$file" in
            homebrew/Brewfile)
                git add homebrew/Brewfile
                git commit -m "Автоматическое обновление Brewfile"
                ;;
            iterm2/*)
                git add iterm2/
                git commit -m "Автоматическое обновление iTerm2 конфигурации"
                ;;
            vscode/*)
                git add vscode/
                git commit -m "Автоматическое обновление VS Code конфигурации"
                ;;
            cursor/*)
                # Проверяем файлы на наличие ключей
                if ! ./scripts/security_check.sh cursor/; then
                    noti -t "Ошибка безопасности: dotfiles" -m "Обнаружены потенциальные API ключи в файлах конфигурации Cursor.
                    
Пожалуйста, используйте переменные окружения вместо прямого указания ключей." -e
                    # Выходим немедленно, не записывая в лог
                    exit 1
                fi
                git add cursor/
                git commit -m "Автоматическое обновление Cursor конфигурации"
                ;;
            .zshrc)
                git add .zshrc
                git commit -m "Автоматическое обновление .zshrc"
                ;;
            .zprofile)
                git add .zprofile
                git commit -m "Автоматическое обновление .zprofile"
                ;;
            launchd/com.dotfiles.homebrew_monthly.plist)
                git add launchd/com.dotfiles.homebrew_monthly.plist
                git commit -m "Автоматическое обновление launchd-профиля Homebrew"
                ;;
            scripts/homebrew_monthly_update.sh|homebrew/update_homebrew.sh)
                git add scripts/homebrew_monthly_update.sh homebrew/update_homebrew.sh
                git commit -m "Автоматическое обновление скриптов Homebrew monthly"
                ;;
            *)
                echo "$(date): Неизвестный файл или папка: $file. Пропускаем." >> "$LOG_FILE"
                ;;
        esac
    done

    # Добавляем лог-файл в коммит
    git add "$LOG_FILE"
    git commit -m "Обновлены логи выполнения задач"
    git push
    echo "$(date): Изменения и логи успешно отправлены." >> "$LOG_FILE"

    # Уведомление через noti с контекстом
    current_time=$(date '+%Y-%m-%d %H:%M:%S')
    noti -t "Git Push: dotfiles" -m "Задача monthly обновлена и отправлена в GitHub.

Время: $current_time" -e

    # Возвращаем лог-файл в отслеживаемые (если нужно)
    git update-index --no-assume-unchanged "$LOG_FILE"
else
    echo "$(date): Изменений нет. Логи остаются локально." >> "$LOG_FILE"
fi 