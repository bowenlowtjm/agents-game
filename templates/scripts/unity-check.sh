#!/usr/bin/env bash
# Headless Unity compile-error check for the agent — no Editor focus, no clicks.
# Run this right after writing/editing C#; branch on the exit code.
#
# Two modes (auto-detected):
#   1) Live Editor open + LocalRefreshServer running  -> HTTP (fast, no reload of a 2nd Editor)
#   2) No live Editor                                 -> CLI batchmode + logFile parse
#
# Env:
#   PULLY_REFRESH_PORT  default 8090   - MUST be unique per parallel run (see 11-Parallel-Runs.md)
#   UNITY_BIN                          - path to the Unity executable (CLI mode only)
#   UNITY_PROJECT       default: cwd   - project path (CLI mode)
#
# Exit: 0 = clean, 1 = compile errors (printed).
set -euo pipefail
PORT="${PULLY_REFRESH_PORT:-8090}"
PROJ="${UNITY_PROJECT:-$(pwd)}"

# --- Mode 1: live Editor over HTTP ---
if curl -fsS "http://localhost:${PORT}/health" >/dev/null 2>&1; then
  echo "[unity-check] live Editor on :$PORT — refreshing"
  curl -fsS "http://localhost:${PORT}/refresh" >/dev/null
  sleep 2   # let the recompile + domain reload finish
  ERR="$(curl -fsS "http://localhost:${PORT}/errors" || true)"
  if [ "$ERR" = "CLEAN" ] || [ -z "$ERR" ]; then
    echo "[unity-check] CLEAN"; exit 0
  fi
  echo "[unity-check] COMPILE ERRORS:"; echo "$ERR"; exit 1
fi

# --- Mode 2: CLI batchmode fallback ---
: "${UNITY_BIN:?no live Editor and UNITY_BIN unset — set UNITY_BIN to the Unity executable}"
mkdir -p Logs
echo "[unity-check] no live Editor — batchmode compile (logFile)"
set +e
"$UNITY_BIN" -batchmode -quit -projectPath "$PROJ" \
  -executeMethod AutoRefresher.RefreshAndExit -logFile Logs/compile.log
CODE=$?
set -e
ERRS="$(grep -E 'error CS[0-9]+' Logs/compile.log || true)"
if [ -n "$ERRS" ] || [ "$CODE" -ne 0 ]; then
  echo "[unity-check] COMPILE ERRORS:"; echo "${ERRS:-see Logs/compile.log}"; exit 1
fi
echo "[unity-check] CLEAN"; exit 0
