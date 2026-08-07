#!/bin/bash
# =============================================================================
#  make-student-slips.sh  --  one credential slip per student
#
#  RUN THIS ON HIVE, as yourself:
#      bash make-student-slips.sh
#
#  Reads ~/proteomics-class-users.txt (readable only by you) and writes one slip
#  per student into ~/student-slips/. Each slip contains ONLY that student's own
#  username and password, so handing one out never exposes anybody else.
#
#  Two formats per student, because the two ways you hand these out want
#  different things:
#      <user>.txt   paste-ready — for a Canvas private comment or an e-mail
#      <user>.html  printable card — open in a browser and print, or attach
#
#  Nothing is printed to the screen except counts, so no password lands in your
#  terminal scrollback (or in anyone's shoulder-view).
# =============================================================================
set -euo pipefail

CREDS="${1:-$HOME/proteomics-class-users.txt}"
OUT="${2:-$HOME/student-slips}"
COURSE=/quobyte/proteomics-grp/2026_shortcourse_data

[ -r "$CREDS" ] || { echo "cannot read $CREDS"; exit 1; }

rm -rf "$OUT"
mkdir -p "$OUT"
chmod 700 "$OUT"

n=0
while read -r user pass rest; do
  [ -n "${user:-}" ] || continue
  case "$user" in \#*) continue ;; esac
  [ -n "${pass:-}" ] || { echo "  ! no password for $user — skipped"; continue; }

  # ---- paste-ready text ----------------------------------------------------
  cat > "$OUT/$user.txt" <<TXT
Proteomics Short Course 2026 — your Hive account
================================================

  Username:  $user
  Password:  $pass

These are yours alone. Please don't share them — they open your own work.

GETTING STARTED
---------------
1. Open PowerShell (Windows) or Terminal (Mac) and connect:

     ssh $user@hive.hpc.ucdavis.edu

   When it asks for the password, nothing appears as you type it — no dots,
   no stars. That is normal. Type it and press Enter.

2. Start Claude Code:

     bash $COURSE/start-claude.sh

   After the first time, just type:  claude-course

That's everything. No API key, nothing to install on your own computer.
The full handout has the rest, including how to copy your results home.

Your account is switched off at the end of the course, so copy anything you
want to keep before then.
TXT

  # ---- printable card ------------------------------------------------------
  cat > "$OUT/$user.html" <<HTML
<!doctype html><html lang="en"><head><meta charset="utf-8">
<title>Hive account — $user</title><style>
body{font:15px/1.6 -apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;
 color:#1c1a17;background:#faf8f4;margin:0;padding:2rem}
.card{max-width:34rem;margin:0 auto;background:#fff;border:1px solid #e7e2d9;border-radius:12px;padding:1.6rem 1.8rem}
h1{font-size:1.15rem;margin:0 0 .2rem}.sub{color:#6b655c;font-size:.9rem;margin:0 0 1.2rem}
.cred{background:#f7f4ee;border:1px solid #e7e2d9;border-radius:8px;padding:.9rem 1.1rem;margin:.9rem 0}
.cred div{margin:.25rem 0}
.k{display:inline-block;min-width:5.5rem;color:#6b655c;font-size:.85rem}
.v{font-family:'SF Mono',Menlo,Consolas,monospace;font-size:1.02rem;font-weight:600}
pre{background:#2b2722;color:#f3ede2;padding:.7rem .9rem;border-radius:8px;overflow-x:auto;
 font-family:'SF Mono',Menlo,Consolas,monospace;font-size:.84rem;margin:.5rem 0}
.warn{background:#fef4f1;border-left:3px solid #c0392b;padding:.7rem 1rem;border-radius:6px;
 font-size:.9rem;margin-top:1.1rem}
ol{padding-left:1.1rem}li{margin:.5rem 0}
@media print{body{background:#fff;padding:0}.card{border:none}}
</style></head><body><div class="card">
<h1>Proteomics Short Course 2026 — your Hive account</h1>
<p class="sub">These are yours alone. Please don't share them.</p>
<div class="cred">
  <div><span class="k">Username</span><span class="v">$user</span></div>
  <div><span class="k">Password</span><span class="v">$pass</span></div>
</div>
<ol>
  <li>Open <strong>PowerShell</strong> (Windows) or <strong>Terminal</strong> (Mac) and connect:
    <pre>ssh $user@hive.hpc.ucdavis.edu</pre>
    Nothing appears as you type the password — no dots, no stars. That is normal.</li>
  <li>Start Claude Code:
    <pre>bash $COURSE/start-claude.sh</pre>
    After the first time, just type <strong>claude-course</strong>.</li>
</ol>
<p>That's everything — no API key, nothing to install on your own computer. The full handout
covers the rest, including how to copy your results home.</p>
<div class="warn"><strong>Your account is switched off when the course ends.</strong>
Copy anything you want to keep before then.</div>
</div></body></html>
HTML

  chmod 600 "$OUT/$user.txt" "$OUT/$user.html"
  n=$((n+1))
done < "$CREDS"

echo "wrote $OUT"
echo "  students     : $n"
echo "  files        : $(ls -1 "$OUT" | wc -l)  (a .txt and a .html each)"
echo "  permissions  : $(ls -ld "$OUT" | cut -d' ' -f1) on the folder, 600 on every slip"
echo
echo "Check one before sending them out:"
echo "  cat $OUT/$(head -1 "$CREDS" | awk '{print $1}').txt"
echo
echo "To bring them to your own computer:"
echo "  scp -r $USER@hive.hpc.ucdavis.edu:student-slips ."
