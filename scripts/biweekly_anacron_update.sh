#!/bin/bash

# Путь к репозиторию
REPO_DIR=~/dotfiles
LOG_FILE="$REPO_DIR/biweekly_update.log"

# Переходим в директорию репозитория
cd $REPO_DIR || exit

# Запускаем обновление Brewfile и ждём завершения
~/dotfiles/scripts/update_brewfile.sh

# Проверяем, есть ли изменения
if git status --porcelain | grep -q "."; then
    echo "$(date): Обнаружены изменения. Начинаем обработку..." >> "$LOG_FILE"

    # Цикл по изменённым файлам или папкам
    git status --porcelain | while read -r status file; do
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
            .zshrc)
                git add .zshrc
                git commit -m "Автоматическое обновление .zshrc"
                ;;
            .zprofile)
                git add .zprofile
                git commit -m "Автоматическое обновление .zprofile"
                ;;
            *)
                echo "$(date): Неизвестный файл или папка: $file. Пропускаем." >> "$LOG_FILE"
                ;;
        esac
    done

    # Отправляем изменения
    git push
    echo "$(date): Изменения успешно отправлены." >> "$LOG_FILE"
else
    echo "$(date): Изменений нет. Завершаем." >> "$LOG_FILE"
fi

# Добавляем лог-файл в репозиторий
git add "$LOG_FILE"
git commit -m "Обновлены логи выполнения задачи"
git push