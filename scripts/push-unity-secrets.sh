#!/usr/bin/env bash
# Push Unity GitHub Actions secrets to a run repo (or org-wide) from the LOCAL
# secrets store. **No secret values live in this script or the repo** — they live
# outside git at ~/.config/pully/ (see SETUP-CREDENTIALS §7).
#
# Why this exists: GitHub Actions secrets are PER-REPO. Each new run repo needs
# UNITY_LICENSE/UNITY_EMAIL/UNITY_PASSWORD or GameCI fails with "No valid license
# activation strategy." This automates it.
#
# Requires: gh (brew install gh && gh auth login).
#
# Usage:
#   scripts/push-unity-secrets.sh bowenlowtjm/<run-repo>     # one repo
#   scripts/push-unity-secrets.sh --org <org>                # org-wide (all repos, once)
set -euo pipefail

STORE="${PULLY_SECRETS:-$HOME/.config/pully/secrets.env}"
[ -f "$STORE" ] || { echo "ERROR: missing $STORE — create it (see SETUP-CREDENTIALS §7)"; exit 1; }
# shellcheck disable=SC1090
source "$STORE"

ULF="${UNITY_LICENSE_FILE:-$HOME/.config/pully/unity.ulf}"
[ -f "$ULF" ] || { echo "ERROR: missing license file $ULF (save your Unity .ulf there)"; exit 1; }
: "${UNITY_EMAIL:?set UNITY_EMAIL in $STORE}"
: "${UNITY_PASSWORD:?set UNITY_PASSWORD in $STORE}"
case "$UNITY_EMAIL" in FILL_ME*) echo "ERROR: $STORE still has placeholder values"; exit 1;; esac

[ $# -ge 1 ] || { echo "usage: $0 <owner/repo> | --org <org>"; exit 1; }

if [ "$1" = "--org" ]; then
  ORG="${2:?usage: $0 --org <org>}"
  gh secret set UNITY_LICENSE  --org "$ORG" --visibility all < "$ULF"
  gh secret set UNITY_EMAIL    --org "$ORG" --visibility all --body "$UNITY_EMAIL"
  gh secret set UNITY_PASSWORD --org "$ORG" --visibility all --body "$UNITY_PASSWORD"
  echo "✅ pushed Unity secrets to org '$ORG' (all repos)"
else
  REPO="$1"
  gh secret set UNITY_LICENSE  --repo "$REPO" < "$ULF"
  gh secret set UNITY_EMAIL    --repo "$REPO" --body "$UNITY_EMAIL"
  gh secret set UNITY_PASSWORD --repo "$REPO" --body "$UNITY_PASSWORD"
  echo "✅ pushed Unity secrets to repo '$REPO'"
fi
