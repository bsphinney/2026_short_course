#!/bin/bash
#
# Proteomics Short Course 2026 — one-click Claude Code launcher (macOS)
#
# HOW TO USE: just double-click this file.
#   • The first time, it installs Claude Code, then asks you to double-click once more.
#   • After that, double-clicking always starts Claude Code.
#

# Work from the folder this file lives in (so it finds api-key.txt)
cd "$(dirname "$0")" || exit 1

echo "==============================================="
echo "   Proteomics Short Course 2026 — Claude Code"
echo "==============================================="
echo

# --- 1. Load the shared course API key from api-key.txt ---
if [ ! -f "api-key.txt" ]; then
  echo "ERROR: I couldn't find 'api-key.txt' next to this launcher."
  echo "Keep all the files together in the same folder and try again."
  echo
  read -n 1 -s -r -p "Press any key to close."
  exit 1
fi

# strip any spaces or line breaks from the key
KEY="$(tr -d ' \t\r\n' < api-key.txt)"
if [ -z "$KEY" ] || [ "$KEY" = "PASTE-YOUR-COURSE-KEY-HERE" ]; then
  echo "ERROR: api-key.txt doesn't have the course key in it yet."
  echo "Ask your instructor for the key if you're missing it."
  echo
  read -n 1 -s -r -p "Press any key to close."
  exit 1
fi
export ANTHROPIC_API_KEY="$KEY"

# make sure the usual install location is on PATH
export PATH="$HOME/.local/bin:$PATH"

# --- 2. Install Claude Code the first time ---
if ! command -v claude >/dev/null 2>&1; then
  echo "First-time setup: installing Claude Code. This takes about a minute..."
  echo
  curl -fsSL https://claude.ai/install.sh | bash
  echo
  echo "-----------------------------------------------------"
  echo "   Install complete!"
  echo "   Now DOUBLE-CLICK this launcher one more time"
  echo "   to start Claude Code."
  echo "-----------------------------------------------------"
  echo
  read -n 1 -s -r -p "Press any key to close."
  exit 0
fi

# --- 3. Start Claude Code ---
echo "Starting Claude Code — type your questions right here in this window."
echo "Tip: stay on the Sonnet 5 model (type /model to check). Type /exit when you're done."
echo
claude
