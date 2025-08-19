#!/usr/bin/env python3
"""Extract user's own public Telegram chats.

Сохраняет channels.json в той же папке.
"""
from __future__ import annotations

import asyncio
import json
import os
import sys
from pathlib import Path

from telethon import TelegramClient
from telethon.tl.custom import Dialog
from telethon.tl.types import Channel, Chat

API_ID = os.getenv("TELEGRAM_API_ID")
API_HASH = os.getenv("TELEGRAM_API_HASH")
SESSION = os.getenv("TELEGRAM_SESSION", str(Path(__file__).with_parent / "session"))

OUTPUT_PATH = Path(__file__).with_suffix(".channels.json")

if not API_ID or not API_HASH:
    print("Set TELEGRAM_API_ID & TELEGRAM_API_HASH in .env", file=sys.stderr)
    sys.exit(1)


async def main() -> None:  # noqa: N802
    async with TelegramClient(SESSION, int(API_ID), API_HASH) as client:
        dialogs: list[Dialog] = await client.get_dialogs()
        # Добавляем архивированные диалоги (folder_id=1)
        dialogs += await client.get_dialogs(folder=1)  # archived
        result = []
        for dlg in dialogs:
            ent = dlg.entity
            if not isinstance(ent, (Channel, Chat)):
                continue
            if not getattr(ent, "username", None):
                continue
            if getattr(ent, "creator", False):
                result.append({
                    "id": ent.id,
                    "title": ent.title,
                    "username": ent.username,
                    "megagroup": getattr(ent, "megagroup", False),
                })
        OUTPUT_PATH.write_text(json.dumps(result, ensure_ascii=False, indent=2))
        print(f"Saved {len(result)} chats to {OUTPUT_PATH}")


if __name__ == "__main__":
    asyncio.run(main())
