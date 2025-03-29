#!/bin/bash

# Путь к репозиторию
REPO_DIR=~/dotfiles

# Функция для обновления расширений VS Code
update_vscode_extensions() {
    if command -v code &> /dev/null; then
        echo "Обновление списка расширений VS Code..."
        code --list-extensions > "$REPO_DIR/vscode/extensions.txt"
        echo "Список расширений VS Code обновлен"
    else
        echo "VS Code не установлен"
    fi
}

# Функция для обновления расширений Cursor
update_cursor_extensions() {
    if command -v cursor &> /dev/null; then
        echo "Обновление списка расширений Cursor..."
        cursor --list-extensions > "$REPO_DIR/cursor/extensions.txt"
        echo "Список расширений Cursor обновлен"
    else
        echo "Cursor не установлен"
    fi
}

# Обновляем расширения для обеих программ
update_vscode_extensions
update_cursor_extensions 