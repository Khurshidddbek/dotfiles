#!/bin/bash

# Anacron-обёртка для ежемесячных задач dotfiles.
# Запускается launchd ежедневно в 12:00 и выполняет run_monthly_tasks.sh,
# если с последнего УСПЕШНОГО прогона прошло INTERVAL_DAYS дней и более.
#
# В отличие от жёсткого расписания «1-го числа в 03:00», не теряет запуск,
# если мак был выключен в назначенный момент: задачи выполнятся в ближайший
# день, когда мак включён. Если прогон завершился с ошибкой (например, не было
# сети для git push), отметка не обновляется — попытка повторится завтра.

set -euo pipefail

REPO_DIR=~/dotfiles
LOG_FILE="$REPO_DIR/scheduled_tasks.log"
STATE_FILE="$HOME/.local/state/dotfiles/last_monthly_run"
INTERVAL_DAYS=30

mkdir -p "$(dirname "$STATE_FILE")"

now=$(date +%s)
last=0
if [[ -f "$STATE_FILE" ]]; then
  last=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
fi
# Защита от повреждённого файла отметки
[[ "$last" =~ ^[0-9]+$ ]] || last=0

elapsed_days=$(( (now - last) / 86400 ))

if (( elapsed_days < INTERVAL_DAYS )); then
  # Ещё рано — выходим тихо, чтобы не засорять лог ежедневными записями.
  exit 0
fi

echo "$(date): Anacron: прошло $elapsed_days дн. с последнего успешного прогона — запускаем ежемесячные задачи." >> "$LOG_FILE"

# Уведомляем о старте — чтобы было видно, что автоматика вообще сработала
noti -t "Dotfiles: monthly задачи запущены" -m "Начало: $(date '+%Y-%m-%d %H:%M:%S')\nПрошло $elapsed_days дн. с последнего прогона." || true

if "$REPO_DIR/scripts/scheduled/run_monthly_tasks.sh"; then
  echo "$now" > "$STATE_FILE"
  echo "$(date): Anacron: прогон успешен, отметка обновлена." >> "$LOG_FILE"
else
  echo "$(date): Anacron: прогон завершился с ошибкой, повторная попытка завтра." >> "$LOG_FILE"
fi
