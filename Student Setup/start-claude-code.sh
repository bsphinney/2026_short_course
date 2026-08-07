#!/bin/bash
#
# Proteomics Short Course 2026 — Claude Code launcher for Hive (Linux / SSH)
#
# HOW TO USE, from your Hive terminal:
#   1. cd into the folder that holds this script and api-key.txt
#   2. run:   bash start-claude-code.sh
#   The FIRST run installs Claude Code into your home directory.
#   Run the SAME command again to start Claude Code.
#

# Work from the folder this script lives in (so it finds api-key.txt)
cd "$(dirname "$0")" || exit 1

echo "==============================================="
echo "   Proteomics Short Course 2026 — Claude Code"
echo "==============================================="
echo

# --- 1. Load the shared course API key from api-key.txt ---
if [ ! -f "api-key.txt" ]; then
  echo "ERROR: api-key.txt not found in this folder:"
  echo "   $(pwd)"
  echo "Make sure api-key.txt is sitting next to this script."
  exit 1
fi

KEY="$(tr -d ' \t\r\n' < api-key.txt)"
if [ -z "$KEY" ] || [ "$KEY" = "PASTE-YOUR-COURSE-KEY-HERE" ]; then
  echo "ERROR: api-key.txt doesn't contain the course key yet."
  echo "Ask your instructor for the key if you're missing it."
  exit 1
fi
export ANTHROPIC_API_KEY="$KEY"

# make sure the standard install location is on PATH
export PATH="$HOME/.local/bin:$PATH"

# --- 2. Install Claude Code the first time (into your home dir, no admin needed) ---
if ! command -v claude >/dev/null 2>&1; then
  echo "First-time setup: installing Claude Code into your home directory..."
  echo "(This takes about a minute and needs internet access from Hive.)"
  echo
  curl -fsSL https://claude.ai/install.sh | bash
  echo
  echo "-----------------------------------------------------"
  echo "   Install complete!"
  echo "   Now run this again to start Claude Code:"
  echo
  echo "        bash start-claude-code.sh"
  echo "-----------------------------------------------------"
  exit 0
fi

# --- 3. Start Claude Code ---
echo "Starting Claude Code — type your questions right here in the terminal."
echo "Tip: stay on the Sonnet 5 model (type /model to check). Type /exit when you're done."
echo
claude
