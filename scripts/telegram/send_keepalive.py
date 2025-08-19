#!/usr/bin/env python3
"""Send keep-alive messages to chats listed in extract_public_chats.channels.json."""
from __future__ import annotations

import asyncio
import json
import os
import random
import sys
from pathlib import Path

from telethon import TelegramClient
from telethon.errors import FloodWaitError

API_ID = os.getenv("TELEGRAM_API_ID")
API_HASH = os.getenv("TELEGRAM_API_HASH")
SESSION = os.getenv("TELEGRAM_SESSION", str(Path(__file__).with_parent / "session"))

CHANNELS_FILE = Path(__file__).with_name("extract_public_chats.channels.json")

MESSAGES = os.getenv("KEEPALIVE_MESSAGES", "ping,👋,keep-alive,⚡️").split(",")

if not CHANNELS_FILE.exists():
    print(f"Channels file {CHANNELS_FILE} not found. Run extract_public_chats.py first.", file=sys.stderr)
    sys.exit(1)

if not API_ID or not API_HASH:
    print("Set TELEGRAM_API_ID & TELEGRAM_API_HASH in .env", file=sys.stderr)
    sys.exit(1)

channels = json.loads(CHANNELS_FILE.read_text())
if not channels:
    print("No channels to process.")
    sys.exit(0)


async def main() -> None:  # noqa: N802
    async with TelegramClient(SESSION, int(API_ID), API_HASH) as client:
        for info in channels:
            username = info["username"]
            text = random.choice(MESSAGES)
            try:
                await client.send_message(username, text)
                print(f"Sent to {username}: {text}")
            except FloodWaitError as e:
                print(f"FloodWait {e.seconds}s… waiting")
                await asyncio.sleep(e.seconds)
                await client.send_message(username, text)


if __name__ == "__main__":
    asyncio.run(main())
