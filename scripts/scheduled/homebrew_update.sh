#!/bin/bash

# Обновление Homebrew (ежемесячное).
# Запускается планировщиком через launchd.

REPO_DIR=~/dotfiles
LOG_FILE="$REPO_DIR/scheduled_tasks.log"

{
  echo "$(date): ===== Начало ежемесячного обновления Homebrew ====="

  echo "$(date): Обновление индекса Homebrew…"
  brew update

  echo "$(date): Обновление formulae и casks…"
  # --greedy заставит Homebrew обновлять даже auto-update casks
  brew upgrade --greedy
  brew upgrade --cask --greedy

  echo "$(date): Очистка старых версий и кэша…"
  brew cleanup

  echo "$(date): Ежемесячное обновление Homebrew завершено."
} >> "$LOG_FILE" 2>&1
