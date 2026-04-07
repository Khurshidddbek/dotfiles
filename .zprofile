# Установка окружения Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Базовое окружение держим здесь, чтобы Antigravity мог запускать команды
# без интерактивных плагинов из ~/.zshrc.
add_to_path() {
  if [[ -d "$1" && ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

add_to_path "/Users/khurshidddbek/Library/Application Support/JetBrains/Toolbox/scripts"
add_to_path "/Users/khurshidddbek/fvm/default/bin"
add_to_path "$HOME/.pub-cache/bin"
add_to_path "$HOME/.cargo/bin"
add_to_path "/Users/khurshidddbek/Library/Android/sdk/emulator"
add_to_path "/Users/khurshidddbek/Library/Android/sdk/platform-tools"
add_to_path "$HOME/.local/bin"
add_to_path "/Users/khurshidddbek/.codeium/windsurf/bin"
add_to_path "/Users/khurshidddbek/.shorebird/bin"
add_to_path "/Users/khurshidddbek/.antigravity/antigravity/bin"
add_to_path "/opt/homebrew/opt/openjdk@17/bin"

export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"

# Added by Codex for mise shims
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh --shims)"
fi
