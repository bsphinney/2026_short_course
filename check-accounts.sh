#!/bin/bash
# =============================================================================
# check-accounts.sh — are the class accounts ready to run Claude Code?
#
# RUN THIS ON HIVE, as yourself:
#     bash check-accounts.sh                    # check every proteomics-class-*
#     bash check-accounts.sh proteomics-class-31 proteomics-class-32
#
# Checks each account against a known-good reference account, so it stays
# correct even if the group list changes later. Prints a PASS/FAIL line per
# account and exits non-zero if any account would fail in class.
#
# WHY THE SLURM CHECK MATTERS MOST
# Since 2026-08-04 start-claude.sh runs `srun --account=publicgrp
# --partition=low` before Claude starts. An account without that association
# cannot start Claude AT ALL — srun rejects it outright. Before that change the
# same account would have limped along on the login node, so this is a new way
# for a half-provisioned account to fail, and it fails at the worst moment.
#
# No passwords are read or printed. Safe to run with someone looking over your
# shoulder.
# =============================================================================
set -uo pipefail

REFERENCE=${REFERENCE:-proteomics-class-07}
CREDS=${CREDS:-$HOME/proteomics-class-users.txt}
COURSE_DIR=/quobyte/proteomics-grp/2026_shortcourse_data
HANDOUTS="$COURSE_DIR/handouts"

BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GRN=$'\033[32m'; YEL=$'\033[33m'; OFF=$'\033[0m'

# sacctmgr lives on cvmfs and is missing from a non-interactive shell's PATH.
SACCTMGR=$(command -v sacctmgr 2>/dev/null || true)
[ -n "$SACCTMGR" ] || SACCTMGR=/cvmfs/hpc.ucdavis.edu/sw/spack/environments/core/view/generic/slurm/bin/sacctmgr
if [ ! -x "$SACCTMGR" ]; then
  printf '%s\n' "${RED}Cannot find sacctmgr — run this on Hive.${OFF}"
  exit 2
fi

# --- what does a good account look like? -------------------------------------
# Taken from the reference rather than hardcoded, minus its own private group,
# which is per-user by definition and would never match anyone else.
if ! id "$REFERENCE" >/dev/null 2>&1; then
  printf '%s\n' "${RED}Reference account $REFERENCE does not exist.${OFF}"
  printf '%s\n' "Set REFERENCE=<a known-good account> and try again."
  exit 2
fi
REQ_GROUPS=$(id -nG "$REFERENCE" 2>/dev/null | tr ' ' '\n' | grep -vx "$REFERENCE" | sort)

printf '%s\n' "${BOLD}Class account readiness check${OFF}"
printf '%s\n' "${DIM}reference: $REFERENCE"
printf '%s\n' "required groups: $(echo "$REQ_GROUPS" | tr '\n' ' ')"
printf '%s\n' "required slurm : publicgrp on partition low${OFF}"
echo

# --- which accounts? ---------------------------------------------------------
if [ "$#" -gt 0 ]; then
  ACCOUNTS=("$@")
else
  # These accounts come from a directory service that does not support
  # enumeration, so `getent passwd` lists none of them even though `id` resolves
  # each one fine. Probe the numeric range by name instead, and union that with
  # the group's membership. The probe is what catches an account that exists but
  # was never added to proteomics-grp — precisely the case the group listing
  # alone would hide.
  SCAN_TO=${SCAN_TO:-40}
  mapfile -t ACCOUNTS < <(
    {
      for n in $(seq -w 1 "$SCAN_TO"); do
        id "proteomics-class-$n" >/dev/null 2>&1 && echo "proteomics-class-$n"
      done
      getent group proteomics-grp 2>/dev/null | awk -F: '{print $4}' \
        | tr ',' '\n' | grep '^proteomics-class-' || true
    } | sort -u
  )
fi

if [ "${#ACCOUNTS[@]}" -eq 0 ]; then
  printf '%s\n' "${RED}No proteomics-class-* accounts found.${OFF}"
  exit 2
fi

fails=0; passes=0; warns=0

for acct in "${ACCOUNTS[@]}"; do
  problems=()
  notes=()

  if ! id "$acct" >/dev/null 2>&1; then
    printf '%s %s\n' "${RED}FAIL${OFF}" "$acct — no such account (not created yet)"
    fails=$((fails+1))
    continue
  fi

  # 1. Unix groups. proteomics-grp is not cosmetic: the handouts directory is
  #    drwxrws--- with no world bits, so a non-member cannot read the course
  #    materials even though start-claude.sh itself is world-readable.
  have=$(id -nG "$acct" 2>/dev/null | tr ' ' '\n' | sort)
  missing=$(comm -23 <(echo "$REQ_GROUPS") <(echo "$have") | tr '\n' ' ')
  [ -n "${missing// /}" ] && problems+=("missing group(s): ${missing% }")

  # 2. The association srun needs. This is the one that stops Claude starting.
  if ! "$SACCTMGR" -nP show assoc user="$acct" format=Account,Partition 2>/dev/null \
       | grep -qx 'publicgrp|low'; then
    problems+=("no slurm association publicgrp/low — CANNOT START CLAUDE")
  fi

  # 3. A home directory to install Claude Code into and write results to.
  home=$(getent passwd "$acct" | cut -d: -f6)
  if [ -z "$home" ] || [ ! -d "$home" ]; then
    problems+=("home directory missing (${home:-unset})")
  fi

  # 4. Not fatal on its own, but it means the slips PDF and Get-My-Results.ps1
  #    will not include this student until the credentials file is updated.
  if [ -r "$CREDS" ]; then
    if ! awk '{print $1}' "$CREDS" 2>/dev/null | grep -qx "$acct"; then
      notes+=("not in $(basename "$CREDS") — no slip, not in Get-My-Results.ps1")
    fi
  fi

  if [ "${#problems[@]}" -gt 0 ]; then
    printf '%s %s\n' "${RED}FAIL${OFF}" "$acct"
    for p in "${problems[@]}"; do printf '       %s\n' "$p"; done
    for n in "${notes[@]}";    do printf '       %s\n' "$n"; done
    fails=$((fails+1))
  elif [ "${#notes[@]}" -gt 0 ]; then
    printf '%s %s\n' "${YEL}WARN${OFF}" "$acct"
    for n in "${notes[@]}"; do printf '       %s\n' "$n"; done
    warns=$((warns+1))
  else
    printf '%s %s\n' "${GRN}PASS${OFF}" "$acct"
    passes=$((passes+1))
  fi
done

# --- shared prerequisites, checked once --------------------------------------
echo
for d in "$COURSE_DIR" "$HANDOUTS"; do
  [ -d "$d" ] || printf '%s\n' "${RED}missing: $d${OFF}"
done
[ -x "$COURSE_DIR/start-claude.sh" ] || \
  printf '%s\n' "${RED}start-claude.sh is missing or not executable${OFF}"

printf '%s\n' "${BOLD}$passes ready · $warns need a rebuild · $fails not ready${OFF}"

if [ "$warns" -gt 0 ] && [ "$fails" -eq 0 ]; then
  cat <<EOF

${YEL}Accounts exist but are not in the credentials file yet.${OFF} Add them to
$CREDS (one "username password" per line), then rebuild the two private files:

    bash fill-in-passwords.sh
    bash make-student-slips.sh
    python3 make-slips-pdf.py

and re-copy student-slips.pdf and Get-My-Results.ps1 into
final_handouts/2-hand-out-privately/.
EOF
fi

# One real test remains that this script cannot do: actually running srun as the
# student. That needs their login. If you want certainty for a new account, log
# in as them once and run claude-course — it either lands on a compute node or
# tells you exactly what is wrong.
[ "$fails" -eq 0 ]
