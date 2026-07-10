# =============================================================================
#                               ЗАГОЛОВОК
# =============================================================================

# Держим агентский терминал максимально тихим, чтобы Antigravity стабильно
# читал stdout/stderr и не цеплял интерактивные плагины.
if [[ -n "${ANTIGRAVITY_AGENT:-}" ]]; then
  PROMPT='%# '
  PS1="$PROMPT"
  RPROMPT=''
  unset PROMPT_COMMAND
  return
fi

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

# Автокоррекция команд намеренно отключена: раньше ENABLE_CORRECTION задавалась
# ПОСЛЕ загрузки oh-my-zsh и не действовала. Автоправку легко включить, задав
# ENABLE_CORRECTION="true" ДО `source $ZSH/oh-my-zsh.sh`, но она чаще мешает.

# Настройки автозавершения и других функций
# Вы можете раскомментировать и настроить по своему усмотрению
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"
# COMPLETION_WAITING_DOTS="true"

# Настройки автообновления oh-my-zsh
zstyle ':omz:update' mode auto      # Автоматическое обновление без запроса
zstyle ':omz:update' frequency 90    # Частота автообновления (в днях)

# =============================================================================
#                            ИСТОРИЯ КОМАНД
# =============================================================================

# Размер истории команд
export HISTSIZE=50000
export SAVEHIST=50000

# Качество истории: убираем дубли и лишние пробелы, делимся историей между
# сессиями сразу. Хорошо сочетается с mcfly (Ctrl-R) и zoxide.
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt SHARE_HISTORY INC_APPEND_HISTORY

# =============================================================================
#                              АЛИАСЫ
# =============================================================================


# Утилиты для Flutter
alias reinstall-pods='f clean && f pub get && cd ios && rm -rf Pods Podfile.lock && pod repo update && pod install && cd .. && noti -t "Cocoapods" -m "Pods reinstalled successfully"'

alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --group-directories-first --git"
alias la="eza -la --icons --group-directories-first --git"
alias lt="eza --tree --level=2 --icons --group-directories-first"

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

alias analyze="dart analyze"
alias analyze-full="dart run dart_code_metrics:metrics analyze lib"

# Added by Codex for mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Claude Code provider overrides (local secrets live outside dotfiles).
# Enable manually with: export CLAUDE_USE_AGENTROUTER=1
if [[ "${CLAUDE_USE_AGENTROUTER:-}" == "1" && -f "$HOME/.config/claude-code/agentrouter.env" ]]; then
  source "$HOME/.config/claude-code/agentrouter.env"
fi

# Antigravity Alias
alias ag="antigravity"

# Added by Antigravity (путь уже добавляется идемпотентно в .zprofile —
# здесь достаточно одной строки на случай запуска без .zprofile)
export PATH="/Users/khurshidddbek/.antigravity/antigravity/bin:$PATH"
