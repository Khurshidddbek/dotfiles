# Cursor MCP Settings

Этот каталог содержит настройки для Cursor MCP серверов.

## Установка

1. Создайте символическую ссылку для `mcp.json`:
```bash
ln -s ~/dotfiles/cursor/mcp.json ~/.cursor/mcp.json
```

2. Создайте файл `.env` в директории `~/.cursor/`:
```bash
cp ~/dotfiles/cursor/.env.template ~/.cursor/.env
```

3. Отредактируйте `~/.cursor/.env` и замените `your_key_here` на ваш реальный ключ MCP:
```bash
CURSOR_MCP_KEY=ваш_реальный_ключ
```

4. Перезапустите Cursor для применения изменений

## Безопасность

⚠️ Файл `.env` с реальным ключом должен храниться только локально в `~/.cursor/.env`
⚠️ Никогда не добавляйте файл `.env` с реальным ключом в публичный репозиторий! 

## Конфигурационные файлы Cursor

Для того чтобы изменения в локальных настройках Cursor автоматически отражались в этом репозитории, используются символические ссылки. При необходимости выполните следующие команды:

```bash
ln -sf ~/dotfiles/cursor/extensions.txt ~/.cursor/extensions/extensions.json
ln -sf ~/dotfiles/cursor/keybindings.json ~/Library/Application\ Support/Cursor/User/keybindings.json
ln -sf ~/dotfiles/cursor/settings.json ~/Library/Application\ Support/Cursor/User/settings.json
``` 