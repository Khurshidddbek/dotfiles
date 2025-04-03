#!/bin/bash

# Функция для проверки файла на наличие потенциальных ключей MCP
check_mcp_keys() {
    local file="$1"
    # Паттерн для ключей MCP (UUID формат)
    local uuid_pattern='[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
    
    # Проверяем наличие ключей в формате UUID в значениях "--key"
    if grep -Ei "\"--key\",\s*\"${uuid_pattern}\"" "$file" > /dev/null; then
        echo "⚠️ ВНИМАНИЕ: Обнаружен потенциальный MCP ключ в файле $file в аргументах --key"
        echo "Найденный ключ:"
        grep -Ei "\"--key\",\s*\"${uuid_pattern}\"" "$file"
        echo "Пожалуйста, используйте переменные окружения вместо прямого указания ключей."
        return 1
    fi
    
    # Проверяем наличие просто UUID в файле (для других возможных форматов)
    if grep -Ei "\"${uuid_pattern}\"" "$file" > /dev/null; then
        echo "⚠️ ВНИМАНИЕ: Обнаружен потенциальный MCP ключ в файле $file"
        echo "Найденный ключ:"
        grep -Ei "\"${uuid_pattern}\"" "$file"
        echo "Пожалуйста, используйте переменные окружения вместо прямого указания ключей."
        return 1
    fi
    
    return 0
}

# Проверяем все JSON файлы в директории cursor
check_directory() {
    local dir="$1"
    local has_error=0

    for file in "$dir"/*.json; do
        if [ -f "$file" ]; then
            if ! check_mcp_keys "$file"; then
                has_error=1
            fi
        fi
    done

    return $has_error
}

# Если скрипт запущен напрямую
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ -z "$1" ]; then
        echo "Использование: $0 <директория>"
        exit 1
    fi

    check_directory "$1"
    exit $?
fi 