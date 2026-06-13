#!/usr/bin/env bash
# Post a message to a Discord channel as the bot (agent -> human).
# Creds from the LOCAL store (~/.config/pully/secrets.env): DISCORD_BOT_TOKEN,
# HERMES_UPDATE_CHANNEL. No secrets in this file.
#
# Usage: discord-send.sh "message text" [channel_id]
set -euo pipefail
STORE="${PULLY_SECRETS:-$HOME/.config/pully/secrets.env}"
[ -f "$STORE" ] || { echo "missing $STORE"; exit 1; }
# shellcheck disable=SC1090
source "$STORE"
: "${DISCORD_BOT_TOKEN:?set DISCORD_BOT_TOKEN in $STORE}"
MSG="${1:?usage: discord-send.sh \"message\" [channel_id]}"
CH="${2:-${HERMES_UPDATE_CHANNEL:?set HERMES_UPDATE_CHANNEL or pass a channel id}}"

body="$(python3 -c 'import json,sys; print(json.dumps({"content": sys.argv[1]}))' "$MSG")"
code=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" -H "Content-Type: application/json" \
  -d "$body" "https://discord.com/api/v10/channels/$CH/messages")
case "$code" in
  200|201) echo "sent" ;;
  403) echo "ERROR 403: bot lacks Send Messages in channel $CH"; exit 1 ;;
  401) echo "ERROR 401: bad bot token"; exit 1 ;;
  *)   echo "ERROR: HTTP $code"; exit 1 ;;
esac
