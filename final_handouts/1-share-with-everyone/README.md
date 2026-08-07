# Short Course 2026 — student files

Everything you need for the course. Start with the handout.

## 📖 Start here

**[HANDOUT-hive-start-here.md](HANDOUT-hive-start-here.md)** — the whole course, start to finish.
Click it and it opens right here in your browser.

*(`HANDOUT-hive-start-here.html` is the same document in a prettier layout. GitHub won't
display HTML — it shows the code instead — so download that one only if you want to print it.)*

The three commands it all comes down to:

```
ssh proteomics-class-NN@hive.hpc.ucdavis.edu     # NN is your own number
claude-course                                     # starts Claude Code
```

Then ask for what you want in plain English — and always say **"the species is mouse"**.

## 📥 Getting things back to your own computer

> [!IMPORTANT]
> Both tools come in **two files that must sit in the same folder**. Download both, put them
> together (Downloads is fine), then double-click the **`.cmd`** one — never the `.ps1`.
> Windows refuses to run a downloaded `.ps1` directly, which is exactly what the `.cmd` is for.
>
> To download from this page: click the file, then use the **download button** (⤓, top right of
> the file view). Don't use *File → Save As* in your browser — that saves the web page, not the file.

**Quicker: let PowerShell fetch both for you.** Open PowerShell and paste this — it puts both
raw-data files on your Desktop, correctly named and together:

```powershell
cd $HOME\Desktop
curl.exe -L -o "Get-My-Raw-Data.ps1" https://raw.githubusercontent.com/bsphinney/2026_short_course/main/final_handouts/1-share-with-everyone/Get-My-Raw-Data.ps1
curl.exe -L -o "Get My Raw Data.cmd" https://raw.githubusercontent.com/bsphinney/2026_short_course/main/final_handouts/1-share-with-everyone/Get%20My%20Raw%20Data.cmd
```

Then double-click **Get My Raw Data.cmd** on your Desktop. If it says *"Cannot find
Get-My-Raw-Data.ps1"*, only one of the two arrived — run the lines above again.

### Your results — small, do this one

| File | |
|---|---|
| `Get My Results.cmd` | double-click this |
| `Get-My-Results.ps1` | **ask your instructor** — it isn't on GitHub |

The `.ps1` half holds every class password, so it's handed out privately rather than published.
If you can't find it here, that's deliberate.

### Your raw data — large, only if you need it

| File | |
|---|---|
| `Get My Raw Data.cmd` | double-click this |
| `Get-My-Raw-Data.ps1` | download this too, into the same folder |

It asks for your Hive username and your initials, tells you how many runs matched and how big
they are, and waits for you to say yes before downloading anything.

> [!WARNING]
> **Raw runs are big.** One run is about **2.2 GB**. Your own four are about **8 GB**. A whole
> bench group is 60–90 GB, and the entire course dataset is **235 GB**. On classroom wi-fi, with
> everyone copying at once, this is slow for the whole room.
>
> **You don't need the raw files to do the course.** Claude searches them where they already sit
> on Hive, which is far faster than moving them. Copy them only if you want to open a run in
> Bruker software on your own PC — and take your own runs, not a whole bench.

## Stuck?

The last section of the handout covers what usually goes wrong. Beyond that, ask Claude —
explaining errors is one of the things it's best at.
