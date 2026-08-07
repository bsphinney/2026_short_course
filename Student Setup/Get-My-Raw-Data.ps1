# =============================================================================
#  Get-My-Raw-Data.ps1 — copy your own raw .d runs from Hive to this PC
#
#  Run it by double-clicking "Get My Raw Data.cmd" (not this file — Windows
#  blocks downloaded .ps1 files from running directly).
#
#  You type your own Hive password, so there is nothing secret in this file.
#
#  READ THIS FIRST: one raw run is about 2.2 GB. Your own four runs are about
#  8 GB. A whole bench group is 80 GB+ and the entire course dataset is 235 GB.
#  This script always shows you the size and asks before it downloads anything.
# =============================================================================

$ErrorActionPreference = 'Stop'
$HiveHost = 'hive.hpc.ucdavis.edu'
$DataDir  = '/quobyte/proteomics-grp/2026_shortcourse_data/2026_data'

function Say($t, $c = 'Gray') { Write-Host $t -ForegroundColor $c }

Say ''
Say '===============================================' Cyan
Say '  Proteomics Short Course 2026 - get raw data' Cyan
Say '===============================================' Cyan
Say ''

# --- who are you -------------------------------------------------------------
$user = Read-Host 'Your Hive username (e.g. proteomics-class-07)'
if ([string]::IsNullOrWhiteSpace($user)) { Say 'No username given. Nothing to do.' Yellow; Read-Host 'Enter to close'; exit }
$user = $user.Trim()

Say ''
Say 'What do you want to copy?'
Say '  1. My own runs        - about 8 GB  (recommended)'
Say '  2. One prep method of mine - about 2 GB'
Say '  3. A whole bench group     - 60-90 GB  (only if told to)'
$choice = Read-Host 'Choose 1, 2 or 3'

switch ($choice) {
  '1' {
    $ini = Read-Host 'Your initials as they appear in the filenames (e.g. AB-G)'
    $pattern = "*_$($ini.Trim())_*"
  }
  '2' {
    $ini  = Read-Host 'Your initials (e.g. AB-G)'
    $prep = Read-Host 'Which prep - bead, urea, s-trap or UE'
    $pattern = "*_$($ini.Trim())_$($prep.Trim())_*"
  }
  '3' {
    Say 'Only works if your initials end in -G, -R, -B or -Y.' DarkGray
    Say 'If yours do not (e.g. JEJ), use option 1 instead.' DarkGray
    $bench = Read-Host 'Bench group letter - G green, R red, B blue, Y yellow'
    $pattern = "*-$($bench.Trim())_*"
  }
  default { Say 'Not a valid choice.' Yellow; Read-Host 'Enter to close'; exit }
}

# --- what would that actually be ---------------------------------------------
Say ''
Say "Looking on Hive for runs matching  $pattern"
Say 'You will be asked for your Hive password. Nothing appears as you type.' DarkGray
Say ''

# Two things to be careful about in this one line:
#  * -L makes du follow the symlinks, which is what scp will do too. Without it
#    the sizes come back as a few hundred bytes and mean nothing.
#  * No $( ) anywhere. PowerShell evaluates $( ) inside a double-quoted string
#    even when the string is destined for a remote shell, so a command
#    substitution here runs locally and fails on Windows. The matching runs are
#    written to a list file on Hive and fed to du with xargs instead.
$remoteCmd = "cd '$DataDir' && ls -d $pattern 2>/dev/null | grep '_DIA_' > ~/.rawlist; wc -l < ~/.rawlist; xargs -a ~/.rawlist du -shLc 2>/dev/null | tail -1 | cut -f1"
$info = & ssh -o StrictHostKeyChecking=accept-new "$user@$HiveHost" $remoteCmd 2>&1

$lines = @($info | Where-Object { $_ -match '\S' })
if ($lines.Count -lt 2) { Say 'Could not read that from Hive. Check your username, password and initials.' Red; Say $info DarkGray; Read-Host 'Enter to close'; exit }

$count = $lines[0].Trim()
$size  = $lines[-1].Trim()

if ($count -eq '0') { Say 'No runs matched. Check the spelling of your initials.' Yellow; Read-Host 'Enter to close'; exit }

Say ''
Say "  runs matched : $count" White
Say "  total size   : $size" White

# --- room on this PC? --------------------------------------------------------
$dest = Join-Path $env:USERPROFILE 'Desktop\proteomics-raw-data'
$drive = Get-PSDrive -Name ($env:USERPROFILE.Substring(0,1))
$freeGB = [math]::Round($drive.Free / 1GB, 1)
Say "  free on this PC: $freeGB GB" White
Say ''

Say 'This is a big download over the classroom network.' Yellow
Say 'If several people run it at once it will be slow for everybody.' Yellow
Say ''
$go = Read-Host "Download $count runs ($size) to your Desktop? (y/n)"
if ($go -notmatch '^[Yy]') { Say 'Cancelled - nothing downloaded.' Yellow; Read-Host 'Enter to close'; exit }

# --- fetch -------------------------------------------------------------------
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Say ''
Say "Copying into $dest" Cyan
Say 'Password again, please. This can take a while - leave it running.' DarkGray
Say ''

# One scp call = one connection = one password prompt. -r because each .d is a
# folder, and scp follows the symlink to the real data on the raw-data store.
& scp -r -o StrictHostKeyChecking=accept-new "$user@${HiveHost}:$DataDir/$pattern" $dest

if ($LASTEXITCODE -eq 0) {
  Say ''
  Say 'Done.' Green
  $got = (Get-ChildItem $dest -Directory -Filter '*.d' -ErrorAction SilentlyContinue).Count
  Say "  $got .d folders are now in $dest" Green
  Start-Process explorer.exe $dest
} else {
  Say ''
  Say 'That did not finish cleanly.' Red
  Say 'Most often: wrong password, or the transfer was interrupted.' DarkGray
  Say 'You can run this again - it will re-copy what is missing.' DarkGray
}

Say ''
Read-Host 'Press Enter to close'
