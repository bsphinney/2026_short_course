#!/bin/bash
# =============================================================================
# Proteomics Short Course 2026 — start Claude Code on Hive
#
# STUDENTS: this is the only command you need.
#
#     bash /quobyte/proteomics-grp/2026_shortcourse_data/start-claude.sh
#
# It installs Claude Code the first time (into your own home directory, no admin
# needed) and then starts it. You do NOT need the course API key — this script
# already knows where it is.
# =============================================================================
set -uo pipefail

COURSE_DIR=/quobyte/proteomics-grp/2026_shortcourse_data
BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GRN=$'\033[32m'; OFF=$'\033[0m'

# Size of the interactive allocation Claude runs in. Overridable from the
# environment so these can be tuned during a class without editing the logic:
#   CC_CPUS=8 CC_TIME=04:00:00 claude-course
CC_ACCOUNT=${CC_ACCOUNT:-publicgrp}
CC_PARTITION=${CC_PARTITION:-low}
CC_CPUS=${CC_CPUS:-4}
CC_MEM=${CC_MEM:-16G}
CC_TIME=${CC_TIME:-08:00:00}

if [ -z "${SHORTCOURSE_RELAUNCH:-}" ]; then
  printf '%s\n' "${BOLD}=== Proteomics Short Course 2026 — Claude Code ===${OFF}"
fi

# --- 1. find the course key -------------------------------------------------
# Checked in order so the layout can move without breaking the student command.
KEY=""
for f in "$COURSE_DIR/course-key.txt" \
         "$COURSE_DIR/handouts/Student Setup/api-key.txt" \
         "$COURSE_DIR/Student Setup/api-key.txt"; do
  [ -r "$f" ] || continue
  k=$(tr -d ' \t\r\n' < "$f")
  case "$k" in
    sk-ant-*) KEY="$k"; break ;;
  esac
done

if [ -z "$KEY" ]; then
  printf '%s\n' "${RED}The course key has not been set up yet.${OFF}"
  printf '%s\n' "This is not something you can fix — please tell your instructor:"
  printf '%s\n' "  ${DIM}\"start-claude.sh says the course key is missing\"${OFF}"
  exit 1
fi
export ANTHROPIC_API_KEY="$KEY"

# A key exported by hand in a previous session would silently win over this one.
# Warn rather than fight it, because the symptom (billing errors) is baffling.
if [ -n "${ANTHROPIC_AUTH_TOKEN:-}" ]; then
  printf '%s\n' "${DIM}note: ANTHROPIC_AUTH_TOKEN is set in your shell and may override the course key.${OFF}"
fi

# --- 1a. get off the login node ---------------------------------------------
# Claude Code itself is light, but everything it does on the student's behalf —
# unpacking .d folders, python, grepping result tables, an impatient "just run it
# here" — executes wherever Claude is running. Thirty-one of those on the shared
# login node is what gets a class account suspended. So unless we are already
# inside an allocation, hand this same script to srun and re-run it on a compute
# node. SLURM_JOB_ID is set inside the allocation, so the second pass falls
# straight through this block; that is also what stops it recursing.
#
# Partition is 'low' deliberately. publicgrp's share of 'high' is capped at 128
# CPUs for the whole public group and normally sits full (127/128 used with 114
# jobs queued when this was written, and the QOS is DenyOnLimit) — an interactive
# job there would stall or be refused at the worst possible moment. 'low' has no
# such cap. The price is that 'low' is preemptable, handled on the way out below.
if [ -z "${SLURM_JOB_ID:-}" ]; then
  # Slurm lives on cvmfs and is on PATH for a normal interactive login; the
  # literal path is the fallback for a shell that never read /etc/profile.
  SRUN=$(command -v srun 2>/dev/null || true)
  [ -n "$SRUN" ] || SRUN=/cvmfs/hpc.ucdavis.edu/sw/spack/environments/core/view/generic/slurm/bin/srun
  if [ ! -x "$SRUN" ]; then
    printf '%s\n' "${RED}Cannot find srun, so this cannot move off the login node.${OFF}"
    printf '%s\n' "Please stop and tell your instructor — do not run Claude here."
    exit 1
  fi

  # srun --pty needs a real terminal. Without this check a piped or scripted run
  # fails deep inside Slurm with a message no student could act on.
  if [ ! -t 0 ] || [ ! -t 1 ]; then
    printf '%s\n' "${RED}Run this from a terminal you are typing into.${OFF}"
    exit 1
  fi

  # Re-run *this* file, so a copy under test relaunches itself and not the live one.
  # It has to sit on a shared filesystem: the compute node opens this path itself,
  # and anything under /tmp or /scratch is node-local and simply will not be there.
  SELF=$0
  case "$SELF" in /*) ;; *) SELF="$PWD/$SELF" ;; esac
  [ -r "$SELF" ] || SELF="$COURSE_DIR/start-claude.sh"

  # Closing the SmarTTY window instead of typing /exit can leave the old
  # allocation running. Say so, rather than let 4-core reservations quietly
  # stack up all week under one student.
  SQUEUE=$(command -v squeue 2>/dev/null || true)
  [ -n "$SQUEUE" ] || SQUEUE="$(dirname "$SRUN")/squeue"
  if [ -x "$SQUEUE" ]; then
    OLD=$("$SQUEUE" -h -u "$USER" -n claude-course -t RUNNING -o '%i' 2>/dev/null | tr '\n' ' ')
    if [ -n "${OLD// /}" ]; then
      printf '%s\n' "${DIM}note: you already have a Claude session on a compute node (job ${OLD% })."
      printf '%s\n' "If that is a window you closed, free it with: scancel ${OLD% }${OFF}"
    fi
  fi

  printf '%s\n' "Getting you a compute node — usually a few seconds."
  printf '%s\n' "${DIM}${CC_CPUS} cores, ${CC_MEM}, up to ${CC_TIME}. Big searches are still submitted"
  printf '%s\n' "as their own jobs on top of this — this is just your workbench.${OFF}"

  SHORTCOURSE_RELAUNCH=1 "$SRUN" \
      --account="$CC_ACCOUNT" --partition="$CC_PARTITION" \
      --cpus-per-task="$CC_CPUS" --mem="$CC_MEM" --time="$CC_TIME" \
      --job-name=claude-course --pty \
      bash "$SELF" "$@"
  rc=$?

  # 0 means they typed /exit. Anything else on a preemptable partition is usually
  # the cluster reclaiming the node, which looks alarming and loses nothing.
  if [ "$rc" -ne 0 ]; then
    printf '\n%s\n' "${RED}That session ended early.${OFF} Most often the cluster took the node back."
    printf '%s\n' "Your files and Claude's notes are safe in your home directory."
    printf '%s\n' "Start again with ${BOLD}claude-course${OFF} and say ${DIM}\"carry on from where we left off\"${OFF}."
  fi
  exit "$rc"
fi

# --- 2. install Claude Code on first use ------------------------------------
export PATH="$HOME/.local/bin:$PATH"
if ! command -v claude >/dev/null 2>&1; then
  printf '%s\n' "First time here — installing Claude Code into your home directory."
  printf '%s\n' "${DIM}(about a minute; nothing is installed system-wide)${OFF}"
  if ! curl -fsSL https://claude.ai/install.sh | bash; then
    printf '%s\n' "${RED}Install failed.${OFF} Check you have internet from Hive:"
    printf '%s\n' "  curl -I https://claude.ai"
    exit 1
  fi
  hash -r 2>/dev/null || true
  export PATH="$HOME/.local/bin:$PATH"
  if ! command -v claude >/dev/null 2>&1; then
    printf '%s\n' "${RED}Installed, but 'claude' is still not on your PATH.${OFF}"
    printf '%s\n' "Try opening a new terminal and running this command again."
    exit 1
  fi
  printf '%s\n' "${GRN}Installed.${OFF}"
fi

# --- 3. one-time convenience: a short command for next time ------------------
# So the student never has to paste the long path again.
RC="$HOME/.bashrc"
if [ -w "$HOME" ] && ! grep -q 'claude-course()' "$RC" 2>/dev/null; then
  {
    echo ""
    echo "# Proteomics Short Course 2026 — type 'claude-course' to start Claude Code"
    echo "claude-course() { bash $COURSE_DIR/start-claude.sh \"\$@\"; }"
  } >> "$RC" 2>/dev/null && \
  printf '%s\n' "${DIM}tip: next time just type ${BOLD}claude-course${OFF}${DIM} — works in any new login${OFF}"
fi

# --- 3a. make sure a login shell actually reads .bashrc ----------------------
# SSH gives you a LOGIN shell, and bash reads ~/.bash_profile, ~/.bash_login or
# ~/.profile for those — never ~/.bashrc. These accounts ship with none of the
# three, so the function written above is defined in a file nothing ever loads and
# `claude-course` comes back "command not found". Create the conventional bridge.
PROF="$HOME/.bash_profile"
if [ -w "$HOME" ] && [ ! -e "$PROF" ] && [ ! -e "$HOME/.bash_login" ] && [ ! -e "$HOME/.profile" ]; then
  {
    echo "# Added by the Proteomics Short Course setup."
    echo "# Login shells (ssh) do not read ~/.bashrc on their own — this loads it."
    echo '[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"'
  } > "$PROF" 2>/dev/null
fi

# --- 3b. give Claude the course context -------------------------------------
# Claude Code reads CLAUDE.md from the folder it starts in. Students start at home,
# which would otherwise be empty of context — they'd have to explain the data paths,
# the species and the cluster rules every single session. Refresh from the one
# canonical copy so updating the guidance is a single file edit, not 30 accounts.
CTX="$COURSE_DIR/course-CLAUDE.md"
if [ -r "$CTX" ]; then
  if ! cmp -s "$CTX" "$HOME/CLAUDE.md" 2>/dev/null; then
    cp -f "$CTX" "$HOME/CLAUDE.md" 2>/dev/null && \
      printf '%s\n' "${DIM}course context updated (~/CLAUDE.md)${OFF}"
  fi
fi

# --- 3c. short path to the course folder ------------------------------------
# Nobody should have to type /quobyte/proteomics-grp/2026_shortcourse_data. One link
# in their home makes everything reachable as ~/course/... and tab-completable.
if [ ! -e "$HOME/course" ]; then
  ln -sfn "$COURSE_DIR" "$HOME/course" 2>/dev/null && \
    printf '%s\n' "${DIM}course files are at ~/course (2025_data, hela, speclibs)${OFF}"
fi

# --- 4. go -------------------------------------------------------------------
printf '%s\n' "${GRN}On compute node $(hostname -s), job ${SLURM_JOB_ID} — not the login node.${OFF}"
printf '%s\n' "Starting Claude Code. Type your questions in plain English."
printf '%s\n' "${DIM}Sonnet 5 at medium effort — the settings that keep the class inside budget.${OFF}"
printf '%s\n' "${DIM}/model and /effort to check. /exit when done.${OFF}"
echo
cd "$HOME" || exit 1
# Pin BOTH model and effort. Claude Code's own default is Opus 5 at high effort —
# 2.5x Sonnet's output price on a fixed $500 pool shared by 31 students. Sonnet 5
# carries the same proteomics knowledge and the skill does the heavy lifting, so the
# spend buys nothing here. Medium effort is enough to orchestrate a multi-step search
# correctly without paying for thinking tokens nobody reads.
# Both flags precede "$@" so an instructor override still wins.
exec claude --model claude-sonnet-5 --effort medium "$@"
