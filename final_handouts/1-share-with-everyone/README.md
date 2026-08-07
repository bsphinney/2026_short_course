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

**Ask your instructor for the easy version.** It is two files:

| File | |
|---|---|
| `Get My Raw Data EASY.cmd` | double-click this |
| `Get-My-Raw-Data-EASY.ps1` | **ask your instructor** — it isn't on GitHub |

Pick your name from a list, pick your initials from a list, and it downloads. No
password to type. Like the results tool, the `.ps1` half holds the class passwords, so
it is handed out directly rather than published.

<details>
<summary>Or do it yourself without waiting for that file</summary>

These two are on GitHub and work straight away — you just type your own Hive password:

| File | |
|---|---|
| `Get My Raw Data.cmd` | double-click this |
| `Get-My-Raw-Data.ps1` | download this too, into the same folder |

Paste this into PowerShell to fetch both onto your Desktop, correctly named:

```powershell
cd $HOME\Desktop
curl.exe -L -o "Get-My-Raw-Data.ps1" https://raw.githubusercontent.com/bsphinney/2026_short_course/main/final_handouts/1-share-with-everyone/Get-My-Raw-Data.ps1
curl.exe -L -o "Get My Raw Data.cmd" https://raw.githubusercontent.com/bsphinney/2026_short_course/main/final_handouts/1-share-with-everyone/Get%20My%20Raw%20Data.cmd
```

If it says *"Cannot find Get-My-Raw-Data.ps1"*, only one of the two arrived — run it again.

Or skip the scripts entirely and use `scp`, replacing `NN` with your number and `XX-Y`
with your initials:

```powershell
cd $HOME\Desktop
scp -r "proteomics-class-NN@hive.hpc.ucdavis.edu:/quobyte/proteomics-grp/2026_shortcourse_data/2026_data/*_XX-Y_*" .
```

</details>

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
