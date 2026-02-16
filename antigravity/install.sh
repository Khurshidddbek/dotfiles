#!/bin/bash

# Antigravity Settings Restore Script

ANTIGRAVITY_CONFIG_DIR="$HOME/Library/Application Support/Antigravity/User"
DOTFILES_ANTIGRAVITY_DIR="$HOME/dotfiles/antigravity"

echo "Restoring Antigravity settings..."

# Create directory if it doesn't exist
mkdir -p "$ANTIGRAVITY_CONFIG_DIR"

# Backup existing files
if [ -f "$ANTIGRAVITY_CONFIG_DIR/settings.json" ] && [ ! -L "$ANTIGRAVITY_CONFIG_DIR/settings.json" ]; then
    echo "Backing up existing settings.json..."
    mv "$ANTIGRAVITY_CONFIG_DIR/settings.json" "$ANTIGRAVITY_CONFIG_DIR/settings.json.bak"
fi

if [ -f "$ANTIGRAVITY_CONFIG_DIR/keybindings.json" ] && [ ! -L "$ANTIGRAVITY_CONFIG_DIR/keybindings.json" ]; then
    echo "Backing up existing keybindings.json..."
    mv "$ANTIGRAVITY_CONFIG_DIR/keybindings.json" "$ANTIGRAVITY_CONFIG_DIR/keybindings.json.bak"
fi

# Create symlinks
echo "Creating symlinks..."
ln -sf "$DOTFILES_ANTIGRAVITY_DIR/settings.json" "$ANTIGRAVITY_CONFIG_DIR/settings.json"
ln -sf "$DOTFILES_ANTIGRAVITY_DIR/keybindings.json" "$ANTIGRAVITY_CONFIG_DIR/keybindings.json"

# Install extensions
echo "Installing extensions..."
if [ -f "$DOTFILES_ANTIGRAVITY_DIR/extensions.txt" ]; then
    while IFS= read -r extension || [ -n "$extension" ]; do
        # Skip empty lines
        if [ -z "$extension" ]; then
            continue
        fi
        echo "Installing $extension..."
        "$HOME/.antigravity/antigravity/bin/antigravity" --install-extension "$extension"
    done < "$DOTFILES_ANTIGRAVITY_DIR/extensions.txt"
else
    echo "No extensions.txt found."
fi

echo "Antigravity settings restored!"
