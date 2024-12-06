#!/bin/bash

# Определяем путь к файлу Brewfile
REPO_DIR=~/dotfiles
BREWFILE_PATH="$REPO_DIR/homebrew/Brewfile"

# Обновляем Brewfile
brew bundle dump --file="$BREWFILE_PATH" --force &

# Ждём завершения всех фоновых процессов
wait

# Сообщение для логов (если требуется)
echo "$(date): Brewfile обновлён." >> "$REPO_DIR/biweekly_update.log"