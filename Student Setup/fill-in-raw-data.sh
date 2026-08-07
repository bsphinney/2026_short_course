#!/bin/bash
# Fill the class passwords into Get-My-Raw-Data-EASY.ps1.
#
# RUN THIS ON HIVE, as yourself:
#     bash fill-in-raw-data.sh
#
# Reads ~/proteomics-class-users.txt (only you can read it) and writes the
# finished script to ~/Get-My-Raw-Data-EASY.ps1. Nothing is printed to the
# screen, so no password lands in your terminal scrollback.
set -euo pipefail

CREDS="${1:-$HOME/proteomics-class-users.txt}"
TMPL="${2:-$HOME/Get-My-Raw-Data-EASY.ps1.template}"
OUT="${3:-$HOME/Get-My-Raw-Data-EASY.ps1}"

[ -r "$CREDS" ] || { echo "cannot read $CREDS"; exit 1; }
[ -r "$TMPL"  ] || { echo "cannot read $TMPL"; exit 1; }

awk '{
  p = $2
  gsub(/'"'"'/, "'"'"''"'"'", p)
  printf "  @{ User='"'"'%s'"'"'; Pass='"'"'%s'"'"' },\n", $1, p
}' "$CREDS" | sed '$ s/,$//' > /tmp/.rawroster.$$

awk -v rf=/tmp/.rawroster.$$ '
  /__ROSTER__/ { while ((getline line < rf) > 0) print line; next }
  { print }
' "$TMPL" > "$OUT"

rm -f /tmp/.rawroster.$$
chmod 600 "$OUT"

echo "wrote $OUT"
echo "  accounts embedded : $(grep -c "@{ User=" "$OUT" || true)"
echo "  placeholder left  : $(grep -c "__ROSTER__" "$OUT" || true)   (must be 0)"
echo "  permissions       : $(ls -l "$OUT" | cut -d' ' -f1)"
