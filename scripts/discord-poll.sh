#!/usr/bin/env bash
# Receive human messages from a Discord channel (human -> agent).
# Prints NEW non-bot messages since <after_id>, oldest first, as TSV:
#   <message_id>\t<author>\t<content>
# The agent keeps the last id it saw and passes it next poll. Creds from the
# LOCAL store (~/.config/pully/secrets.env). No secrets in this file.
#
# Usage: discord-poll.sh [after_message_id] [channel_id]
#   first call: discord-poll.sh            (returns recent backlog)
#   then:       discord-poll.sh <last_id>  (only newer messages)
set -euo pipefail
STORE="${PULLY_SECRETS:-$HOME/.config/pully/secrets.env}"
[ -f "$STORE" ] || { echo "missing $STORE" >&2; exit 1; }
# shellcheck disable=SC1090
source "$STORE"
: "${DISCORD_BOT_TOKEN:?set DISCORD_BOT_TOKEN in $STORE}"
AFTER="${1:-}"
CH="${2:-${HERMES_UPDATE_CHANNEL:?set HERMES_UPDATE_CHANNEL or pass a channel id}}"

url="https://discord.com/api/v10/channels/$CH/messages?limit=50"
[ -n "$AFTER" ] && url="$url&after=$AFTER"
curl -s -H "Authorization: Bot $DISCORD_BOT_TOKEN" "$url" | python3 -c "
import sys, json
try: msgs = json.load(sys.stdin)
except Exception: sys.exit(0)
for m in reversed(msgs):                 # oldest -> newest
    if m.get('author', {}).get('bot'):   # skip the agent's own posts
        continue
    content = m.get('content', '').replace('\t', ' ').replace('\n', ' ')
    print(m['id'] + '\t' + m['author']['username'] + '\t' + content)
"
