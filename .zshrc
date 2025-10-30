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

# Добавление пути для Pub
export PATH="$PATH":"$HOME/.pub-cache/bin"

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

# Настройка автодополнения Flutter
source ~/dotfiles/flutter/flutter-completion

# =============================================================================
#                            ЗАВЕРШЕНИЕ ФАЙЛА
# =============================================================================

# Добавляем пути, созданные pipx
export PATH="$PATH:/Users/khurshidddbek/.local/bin"

# Added by Windsurf
export PATH="/Users/khurshidddbek/.codeium/windsurf/bin:$PATH"

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/khurshidddbek/.dart-cli-completion/zsh-config.zsh ]] && . /Users/khurshidddbek/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

export PATH="/Users/khurshidddbek/.shorebird/bin:$PATH"

# Added by Windsurf
export PATH="/Users/khurshidddbek/.codeium/windsurf/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
alias analyze="dart analyze"
alias analyze-full="dart run dart_code_metrics:metrics analyze lib"
