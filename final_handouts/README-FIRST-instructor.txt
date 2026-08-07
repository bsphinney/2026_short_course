FINAL HANDOUTS — Proteomics Short Course 2026
=============================================
Assembled 2026-08-04. These are the current versions. Anything not in here is
either instructor-only tooling or has been superseded.

READ THE FOLDER NAMES BEFORE YOU SEND ANYTHING. The split is not cosmetic:
one folder is safe to post publicly, the other leaks every class password.


1-share-with-everyone/          POST ANYWHERE — Canvas, email, shared folder
--------------------------------------------------------------------------
  HANDOUT-hive-start-here.html  The main handout. Meant to be opened in a
                                browser, not printed (it has no print layout).
  READ-ME-FIRST.txt             Explains the folder to students.
  Get My Results.cmd            Downloads a student's results to their PC.

  These contain no passwords and no API key. This is exactly the set that
  already sits in the shared course folder on Hive, at
  /quobyte/proteomics-grp/2026_shortcourse_data/handouts/Student Setup/


2-hand-out-privately/           ONE-TO-ONE ONLY — NEVER post these
--------------------------------------------------------------------------
  student-slips.pdf             All 40 credential slips, two per page with a
                                cut line — 20 pages. THIS IS THE ONLY THING YOU
                                PRINT. Print it, cut it up, hand each student
                                theirs.
  Get-My-Results.ps1            Partner file for "Get My Results.cmd".

  BOTH FILES CONTAIN EVERY CLASS PASSWORD. student-slips.pdf holds all 40 in
  one document; Get-My-Results.ps1 has them embedded so students never type
  one. Hand them out the same way you hand out a password — a Canvas private
  comment, or in person. The folder is mode 700 and the files 600 on purpose.

  Get-My-Results.ps1 is deliberately NOT in the shared Hive folder, because
  the whole class can read that folder. Students must get it from you and save
  it beside "Get My Results.cmd", then double-click the .cmd.


ACCOUNT COUNT — settled 2026-08-05
----------------------------------
40 Hive accounts now exist (proteomics-class-01 .. -40) for 31 students on
roster.csv, so there are 9 spares. All 40 were verified ready: correct groups,
publicgrp/low Slurm association, home directory, and credentials on file.

The slips and Get-My-Results.ps1 in this folder were rebuilt on 2026-08-05 and
cover all 40. Slips exist for the spares too — hand out only what you need.

If accounts are ever added or removed, rebuild both private files or they will
be out of step with reality:

    on Hive:   bash fill-in-passwords.sh        -> ~/Get-My-Results.ps1
               bash make-student-slips.sh       -> ~/student-slips/
               python3 make-slips-pdf.py        -> ~/student-slips.pdf

then re-copy student-slips.pdf and Get-My-Results.ps1 into
2-hand-out-privately/. (make-slips-pdf.py is not kept on Hive; copy it up from
the "Student Setup" folder first.)

To re-verify accounts at any time, copy check-accounts.sh (in the folder above
this one) to Hive and run it:

    bash check-accounts.sh                 # every account
    bash check-accounts.sh proteomics-class-31

It verifies each account has the right groups, has the publicgrp/low Slurm
association, has a home directory, and is present in the credentials file.
The Slurm check is the one that matters most: without that association
srun is rejected and the student cannot start Claude at all.


NOTE ON THE 2026-08-04 COMPUTE-NODE CHANGE
------------------------------------------
Claude Code now moves itself onto a compute node before it starts, so students
never run work on the Hive login node. Nothing they type changed, so the
printed slips were NOT affected and did not need reprinting.

HANDOUT-hive-start-here.html DID change (it explains the new "Getting you a
compute node" pause and adds three troubleshooting rows). The copy here and
the copy on Hive are identical and current. If you posted an older copy to
Canvas, replace it with this one.
