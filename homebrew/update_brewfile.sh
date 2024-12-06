#!/bin/bash

# Определение пути к скрипту и Brewfile
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE_PATH="$SCRIPT_DIR/Brewfile" # Brewfile в той же директории, что и скрипт

# Обновление Brewfile
brew bundle dump --file=$BREWFILE_PATH --force

# Проверка, есть ли репозиторий Git
REPO_DIR="$SCRIPT_DIR/.." # Корень репозитория (на уровень выше)
if [ -d "$REPO_DIR/.git" ]; then
    cd "$REPO_DIR" # Переход в корень репозитория
    git add "$BREWFILE_PATH"
    git commit -m "Автоматическое обновление Brewfile"
    git push
fi