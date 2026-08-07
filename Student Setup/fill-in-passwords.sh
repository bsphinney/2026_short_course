#!/bin/bash
# Fill the class passwords into Get-My-Results.ps1.
#
# RUN THIS ON HIVE, as yourself:
#     bash fill-in-passwords.sh
#
# It reads ~/proteomics-class-users.txt (which only you can read) and writes the
# finished script to ~/Get-My-Results.ps1. Nothing is printed to the screen, so
# the passwords do not end up in your terminal scrollback.
set -euo pipefail

CREDS="${1:-$HOME/proteomics-class-users.txt}"
TMPL="${2:-$HOME/Get-My-Results.ps1.template}"
OUT="${3:-$HOME/Get-My-Results.ps1}"

[ -r "$CREDS" ] || { echo "cannot read $CREDS"; exit 1; }
[ -r "$TMPL"  ] || { echo "cannot read $TMPL (upload Get-My-Results.ps1 and rename it .template)"; exit 1; }

# One PowerShell hashtable per account. Single quotes inside a password are
# doubled, which is how PowerShell escapes them in a single-quoted string.
awk '{
  p = $2
  gsub(/'"'"'/, "'"'"''"'"'", p)
  printf "  @{ User='"'"'%s'"'"'; Pass='"'"'%s'"'"'; Name='"'"''"'"' },\n", $1, p
}' "$CREDS" | sed '$ s/,$//' > /tmp/.roster.$$

awk -v rf=/tmp/.roster.$$ '
  /__ROSTER__/ { while ((getline line < rf) > 0) print line; next }
  { print }
' "$TMPL" > "$OUT"

rm -f /tmp/.roster.$$
chmod 600 "$OUT"

n=$(grep -c "@{ User=" "$OUT" || true)
left=$(grep -c "__ROSTER__" "$OUT" || true)
echo "wrote $OUT"
echo "  accounts embedded : $n"
echo "  placeholder left  : $left   (must be 0)"
echo "  permissions       : $(ls -l "$OUT" | cut -d' ' -f1)   (only you can read it)"
echo
echo "Now copy it to your Windows PC:"
echo "  scp $USER@hive.hpc.ucdavis.edu:Get-My-Results.ps1 ."
