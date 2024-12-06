# =============================================================================
#                               ЗАГОЛОВОК
# =============================================================================

# Задаём путь к oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

# Устанавливаем тему Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Плагины oh-my-zsh
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# =============================================================================
#                               ПУТИ
# =============================================================================

# Функция для добавления путей к PATH
add_to_path() {
  if [[ -d "$1" && ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

# Добавляем пользовательские пути
add_to_path "/Users/khurshidddbek/fvm/default/bin"
add_to_path "$HOME/.pub-cache/bin"
add_to_path "$HOME/.cargo/bin"
add_to_path "/Users/khurshidddbek/Library/Android/sdk/emulator"
add_to_path "/Users/khurshidddbek/Library/Android/sdk/platform-tools"
add_to_path "$HOME/.local/bin"

# =============================================================================
#                           POWERLEVEL10K НАСТРОЙКА
# =============================================================================

# Включаем мгновенный промпт Powerlevel10k (должно быть близко к верху файла)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Загружаем конфигурацию Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =============================================================================
#                            OH-MY-ZSH ИНИЦИАЛИЗАЦИЯ
# =============================================================================

source $ZSH/oh-my-zsh.sh

# =============================================================================
#                               ОПЦИИ SHELL
# =============================================================================

# Включение автоматической коррекции команд
ENABLE_CORRECTION="true"

# Настройки автозавершения и других функций
# Вы можете раскомментировать и настроить по своему усмотрению
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"
# COMPLETION_WAITING_DOTS="true"

# Настройки автообновления oh-my-zsh
zstyle ':omz:update' mode auto      # Автоматическое обновление без запроса
zstyle ':omz:update' frequency 90    # Частота автообновления (в днях)

# =============================================================================
#                              АЛИАСЫ
# =============================================================================

# Альтернативные команды для загрузки видео и аудио
alias download-video='yt-dlp --cookies-from-browser safari --postprocessor-args "-c:v libx264 -crf 23 -preset veryfast"'
alias download-audio='yt-dlp -x --audio-format mp3 --cookies-from-browser safari'

# Инструменты
alias yeelight-toggle='miiocli yeelight --ip 192.168.100.14 --token 8e4593bc136408b71af17dadbcb61bb5 toggle'

# Менеджеры версий Flutter и Dart
alias f="fvm flutter"
alias d="fvm dart"

# Сжатие видео с помощью ffmpeg
alias compress-video='function _cv(){ ffmpeg -i "$1" -vcodec libx264 -crf 24 "${1%.*}_compressed.mp4"; }; _cv'

# Утилиты для Flutter
alias reinstall-pods='f clean && f pub get && cd ios && rm -rf Pods Podfile.lock && pod repo update && pod install && cd .. && noti -t "Cocoapods" -m "Pods reinstalled successfully"'

# =============================================================================
#                              ФУНКЦИИ
# =============================================================================

# Уведомление при выполнении команды
notify_command() {
  command="$@"
  output=$(eval "$command" 2>&1)  # Выполняем команду и сохраняем вывод

  command_status=$?  # Сохраняем статус выполнения команды
  echo "$output"      # Выводим результат команды

  # Воспроизводим звук уведомления
  afplay /Users/khurshidddbek/Do\ not\ delete/Morse.aiff &> /dev/null
  return $command_status  # Возвращаем исходный статус команды
}

# =============================================================================
#                          ПЛАГИНЫ И ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ
# =============================================================================

# История команд с отметками времени (можно настроить формат)
# HIST_STAMPS="yyyy-mm-dd"

# Инициализация плагинов mcfly и zoxide
eval "$(mcfly init zsh)"
eval "$(zoxide init zsh)"

# Настройка автодополнения Dart
[[ -f /Users/khurshidddbek/.dart-cli-completion/zsh-config.zsh ]] && . /Users/khurshidddbek/.dart-cli-completion/zsh-config.zsh || true

# =============================================================================
#                            ЗАВЕРШЕНИЕ ФАЙЛА
# =============================================================================

# Добавляем пути, созданные pipx
export PATH="$PATH:/Users/khurshidddbek/.local/bin"
