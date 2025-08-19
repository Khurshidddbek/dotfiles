#!/bin/bash

# Запуск ежемесячных задач для репозитория dotfiles.
# 1. Обновляет Homebrew (отдельный скрипт homebrew_update.sh) и формирует Brewfile.
# 2. Анализирует изменения и делает единый Git-коммит с перечислением затронутых компонентов.
# 3. Отправляет изменения и выводит уведомление.

set -euo pipefail

REPO_DIR=~/dotfiles
LOG_FILE="$REPO_DIR/scheduled_tasks.log"

cd "$REPO_DIR" || exit 1

echo "$(date): ===== Запуск run_monthly_tasks.sh =====" >> "$LOG_FILE"

# ---------------------------------------------------------------------------
# 1. Обновляем Homebrew и формируем Brewfile
# ---------------------------------------------------------------------------

# Запускаем основной скрипт Homebrew (логирование внутри него)
"$REPO_DIR/scripts/scheduled/homebrew_update.sh"

# Формируем актуальный Brewfile
brew bundle dump --file="$REPO_DIR/homebrew/Brewfile" --force

echo "$(date): Brewfile обновлён." >> "$LOG_FILE"

# ---------------------------------------------------------------------------
# 1b. Отправляем keep-alive в Telegram каналы/группы
# ---------------------------------------------------------------------------
if [[ -f "$REPO_DIR/scripts/telegram/telegram.env" ]]; then
  {
    echo "$(date): Запуск Telegram keep-alive…"
    set +e
    set -a
    # shellcheck source=/dev/null
    source "$REPO_DIR/scripts/telegram/telegram.env"
    set +a
    PYTHON_BIN=$(command -v python3)
    "$PYTHON_BIN" - <<'PY'
import importlib, subprocess, sys
try:
    import telethon  # noqa: F401
except ModuleNotFoundError:
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--quiet', '--user', 'telethon'])
PY
    # теперь запускаем
    "$PYTHON_BIN" "$REPO_DIR/scripts/telegram/extract_public_chats.py"
    "$PYTHON_BIN" "$REPO_DIR/scripts/telegram/send_keepalive.py"
    TELEGRAM_RC=$?
    set -e
    if [[ $TELEGRAM_RC -ne 0 ]]; then
      echo "$(date): Telegram keep-alive завершился с ошибкой code=$TELEGRAM_RC"
    else
      echo "$(date): Telegram keep-alive успешно завершён."
    fi
  } >> "$LOG_FILE" 2>&1
else
  echo "$(date): Telegram env отсутствует, пропускаем keep-alive." >> "$LOG_FILE"
fi

# ---------------------------------------------------------------------------
# 2. Проверяем изменения в репозитории
# ---------------------------------------------------------------------------

if ! git status --porcelain | grep -q "."; then
  echo "$(date): Изменений нет. Завершение." >> "$LOG_FILE"
  exit 0
fi

echo "$(date): Обнаружены изменения. Начинаем обработку..." >> "$LOG_FILE"

declare -a COMMIT_PARTS=()

# Проходим по изменённым файлам и добавляем их в индекс
while read -r file; do
  case "$file" in
    ""|"."|"->")
      # пропускаем пустые/служебные записи
      continue
      ;;
    homebrew/Brewfile)
      git add homebrew/Brewfile
      COMMIT_PARTS+=("homebrew")
      ;;
    iterm2/*)
      git add iterm2/
      COMMIT_PARTS+=("iterm2")
      ;;
    vscode/*)
      git add vscode/
      COMMIT_PARTS+=("vscode")
      ;;
    cursor/*)
      git add cursor/
      COMMIT_PARTS+=("cursor")
      ;;
    flutter/*)
      git add flutter/
      COMMIT_PARTS+=("flutter")
      ;;
    .zshrc)
      git add .zshrc
      COMMIT_PARTS+=(".zshrc")
      ;;
    .zprofile)
      git add .zprofile
      COMMIT_PARTS+=(".zprofile")
      ;;
    launchd/*)
      git add launchd/
      COMMIT_PARTS+=("launchd")
      ;;
    scripts/scheduled/*)
      git add scripts/scheduled/
      COMMIT_PARTS+=("scheduled_scripts")
      ;;
    scripts/telegram/*)
      git add scripts/telegram/
      COMMIT_PARTS+=("telegram_scripts")
      ;;
    scripts/flutter-xcode-cloud/*)
      git add scripts/flutter-xcode-cloud/
      COMMIT_PARTS+=("flutter_xcode_cloud")
      ;;
    "$LOG_FILE")
      # лог обработаем отдельно ниже
      ;;
    *)
      echo "$(date): Неизвестный файл или папка: $file. Пропускаем." >> "$LOG_FILE"
      ;;
  esac
done < <(git status --porcelain | awk '{print $2}')

# Добавляем лог-файл
git add "$LOG_FILE"
COMMIT_PARTS+=("logs")

# Формируем сообщение коммита
COMMIT_MSG="Автоматическое обновление: $(printf '%s, ' "${COMMIT_PARTS[@]}" | sed 's/, $//')"

git commit -m "$COMMIT_MSG"

git push && {
  current_time=$(date '+%Y-%m-%d %H:%M:%S')
  noti -t "Git Push: dotfiles" -m "Monthly задачи обновлены и отправлены в GitHub.\n\nВремя: $current_time" -e
  echo "$(date): Изменения и логи успешно отправлены." >> "$LOG_FILE"
}
