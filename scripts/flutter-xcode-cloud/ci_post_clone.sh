#!/bin/bash

# Включаем режим отладки
set -x

# Прерываем скрипт при любой ошибке
set -e

# Устанавливаем директорию SSH в зависимости от окружения
if [ -n "$CI" ]; then
    SSH_DIR="/Users/local/.ssh"
else
    SSH_DIR="$HOME/.ssh"
fi

echo "Текущая директория: $(pwd)"
echo "Путь к репозиторию: $CI_PRIMARY_REPOSITORY_PATH"

# Переходим в корневую директорию репозитория
cd "$CI_PRIMARY_REPOSITORY_PATH" || exit 1

echo "Перешли в директорию: $(pwd)"
echo "Содержимое директории:"
ls -la

# Настройка SSH для GitHub
echo "Настройка SSH для GitHub..."

# Создаем SSH директорию
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Сохраняем SSH ключ
if [ -n "$SSH_KEY" ]; then
    echo "Сохранение SSH ключа..."
    # Очищаем предыдущие ключи
    rm -f "$SSH_DIR/id_ed25519" "$SSH_DIR/known_hosts"
    
    # Сохраняем и декодируем ключ
    echo "$SSH_KEY" | base64 -d > "$SSH_DIR/id_ed25519"
    chmod 600 "$SSH_DIR/id_ed25519"
    
    # Добавляем GitHub в known_hosts
    echo "Добавление GitHub в known_hosts..."
    ssh-keyscan -t ed25519 github.com > "$SSH_DIR/known_hosts" 2>/dev/null
    chmod 600 "$SSH_DIR/known_hosts"
    
    # Тестируем SSH соединение с подробным выводом
    echo "Проверка SSH соединения..."
    SSH_AUTH_SOCK="" HOME="$(dirname "$SSH_DIR")" ssh -v -i "$SSH_DIR/id_ed25519" -o StrictHostKeyChecking=no -T git@github.com || true
else
    echo "ОШИБКА: SSH_KEY не установлен"
    exit 1
fi

# Настройка Git
echo "Настройка Git для использования SSH..."
# Удаляем существующие конфигурации URL
git config --global --unset-all url."http://github.com/".insteadOf || true
git config --global --unset-all url."https://github.com/".insteadOf || true
git config --global --unset-all url."git@github.com:".insteadOf || true

# Устанавливаем новую конфигурацию URL
git config --global url."git@github.com:".insteadOf "https://github.com/"

# Очищаем кэш учетных данных
git config --global credential.helper ""

# Обновляем URL репозитория
echo "Обновление URL репозитория..."
# ВАЖНО: Замените USERNAME и REPO на ваши значения
git remote set-url origin "git@github.com:USERNAME/REPO.git"

# Проверяем настройки
echo "Проверка Git конфигурации..."
git config --list
git remote -v

# Проверяем текущий remote URL
echo "Текущий remote URL:"
git remote -v

# Проверяем SSH конфигурацию
echo "Проверка SSH конфигурации..."
ssh -T git@github.com || true

# Проверяем новый remote URL
echo "Новый remote URL:"
git remote -v

# Тестируем SSH соединение
echo "Тестируем SSH соединение..."
ssh -T git@github.com || true

# Функция для генерации release notes
generate_release_notes() {
    echo "Генерация release notes..."
    
    # Создаем директорию TestFlight если она не существует
    TESTFLIGHT_DIR_PATH="$CI_PRIMARY_REPOSITORY_PATH/ios/TestFlight"
    mkdir -p "$TESTFLIGHT_DIR_PATH"
    
    # Ищем предыдущий коммит с тегом [build], исключая текущий коммит
    last_build_commit=$(git log --skip=1 --grep="\[build\]" -n 1 --format="%H" || true)
    
    if [ -n "$last_build_commit" ]; then
        # Получаем список коммитов с момента последнего [build] тега
        # Включаем автора, дату и полное сообщение коммита
        commits=$(TZ='Etc/GMT-3' git log --pretty=format:"- %s%n  Автор: %an%n  Дата: %ad (GMT+3)%n  %b%n" --date=format:"%Y-%m-%d %H:%M:%S" $last_build_commit..HEAD | grep -v "\[notes skip\]" || true)
    else
        # Если нет предыдущего [build] тега, берем последние коммиты
        commits=$(TZ='Etc/GMT-3' git log --pretty=format:"- %s%n  Автор: %an%n  Дата: %ad (GMT+3)%n  %b%n" --date=format:"%Y-%m-%d %H:%M:%S" -n 5 | grep -v "\[notes skip\]" || true)
    fi
    
    # Если коммитов нет, используем дефолтное сообщение
    if [ -z "$commits" ]; then
        commits="- Обновление версии сборки"
    fi
    
    # Добавляем дату сборки с GMT+3
    release_notes="Изменения в этой сборке:\n\n$commits\n\nДата сборки: $(TZ='Etc/GMT-3' date '+%Y-%m-%d %H:%M:%S') (GMT+3)"
    
    # Записываем release notes в файл WhatToTest.en-US.txt
    echo -e "$release_notes" > "$TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt"
    
    # Создаем русскую версию
    echo -e "$release_notes" > "$TESTFLIGHT_DIR_PATH/WhatToTest.ru.txt"
    
    echo "Release notes успешно сгенерированы в директории TestFlight"
}

echo "Читаем текущую версию из pubspec.yaml..."
# Увеличиваем build номер
current_version=$(grep "version:" pubspec.yaml | sed 's/version: //')
echo "Текущая версия: $current_version"

version_number=$(echo $current_version | cut -d'+' -f1)
build_number=$(echo $current_version | cut -d'+' -f2)
new_build_number=$((build_number + 1))
new_version="$version_number+$new_build_number"

echo "Новая версия будет: $new_version"

# Обновляем pubspec.yaml
sed -i '' "s/version: .*/version: $new_version/" pubspec.yaml

echo "Установка Flutter..."
FLUTTER_VERSION=$(cat .fvmrc | grep "flutter" | cut -d'"' -f4)
echo "Версия Flutter из .fvmrc: $FLUTTER_VERSION"

git clone https://github.com/flutter/flutter.git --depth 1 -b $FLUTTER_VERSION $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

echo "Версия установленного Flutter:"
flutter --version

# Устанавливаем артефакты Flutter для iOS
echo "Установка артефактов Flutter для iOS..."
flutter precache --ios

# Устанавливаем зависимости Flutter
echo "Установка зависимостей Flutter..."
flutter pub get

# Генерируем release notes
generate_release_notes

# Настраиваем git для коммита
echo "Настройка git..."
# ВАЖНО: Замените EMAIL и NAME на ваши значения
# например: "khurshidddbek+xcodeci@gmail.com", "Xcode Cloud CI"
git config --global user.email "YOUR_EMAIL"
git config --global user.name "YOUR_NAME"

# Коммитим изменения
echo "Коммит изменений..."
git add pubspec.yaml
git commit -m "ci(build): $new_build_number [build] [notes skip] [ci skip]"

# Пробуем push с явным указанием SSH URL
echo "Push изменений..."
# ВАЖНО: Замените USERNAME и REPO на ваши значения
git push git@github.com:USERNAME/REPO.git HEAD:$CI_BRANCH

echo "Установка зависимостей CocoaPods..."
cd ios
pod install

echo "Скрипт успешно завершен"
exit 0
