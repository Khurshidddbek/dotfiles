#!/bin/bash

# brew_upgrade_all.sh
# Скрипт для полного обновления всех пакетов Homebrew (формул и касков)
# Решает проблему, когда стандартная команда brew upgrade не всегда обновляет все пакеты

# Обновляем формулы и каски обычным способом
brew update && brew upgrade

# Обновляем все каски, чтобы получить последнюю версию
brew list --cask | xargs -I{} brew upgrade --cask {}

# Обновляем все формулы, чтобы получить последнюю версию
brew list --formulae | xargs -I{} brew upgrade --formulae {}