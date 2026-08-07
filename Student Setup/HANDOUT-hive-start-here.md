# Start Here

Analysing proteomics data on Hive with Claude Code — Short Course 2026

> [!NOTE]
>
> **This one document replaces the earlier two handouts.** If you have a page telling you to install Claude Code with `curl` or to set something called `ANTHROPIC_API_KEY` yourself — ignore it. You don't need to do either.  
>
> **What you need before you start:** your Hive username and password from your instructor. Your username looks like `proteomics-class-NN`, where NN is your own two-digit number. That's it — no API key, no software to download, nothing to install on your own computer.
>

> [!TIP]
>
> **The whole thing in three steps.** The rest of this handout explains these; if you get lost, come back here.
>
> ```
> # 1. connect — replace NN with YOUR number
> ssh proteomics-class-NN@hive.hpc.ucdavis.edu
>
> # 2. start Claude Code  (just 'claude-course' after the first time)
> bash /quobyte/proteomics-grp/2026_shortcourse_data/start-claude.sh
>
> # 3. inside Claude Code, once ever — install the proteomics skill
> /plugin marketplace add bsphinney/DE-LIMP
> /plugin install ucdavis-proteomics-core-pipeline
> ```
>
> **The `NN` in the commands is the only thing you change.** It is your own two-digit number, printed on your slip — if your slip says *proteomics-class-04*, then `NN` is `04`. Every command in this handout is written the same way: wherever you see `NN`, it is yours to fill in. Copy `NN` as-is and the login will simply be refused.
>
> Then just ask for what you want in plain English — and always say **"the species is mouse"**.
>

## 1. Open a terminal

A *terminal* is a window where you type commands instead of clicking.

| Your computer | How to open it                                  |
|---------------|-------------------------------------------------|
| Mac           | Press `⌘ Space`, type **Terminal**, press Enter |
| Windows 10/11 | Click Start, type **PowerShell**, press Enter   |
| Linux         | Press `Ctrl Alt T`                              |

> [!NOTE]
>
> **Reading the code boxes in this handout.** Type (or paste) only the command itself. Lines starting with `#` are notes to you, not commands. Lines ending in `<- printed by the computer` are what it prints *back* — you don't type those.  
>
> **Pasting into a terminal:** Mac `⌘ V` · Windows PowerShell **right-click** · Linux `Ctrl Shift V`.
>

## 2. Connect to Hive

Type this, replacing `NN` with **your own** number from your slip:

    ssh proteomics-class-NN@hive.hpc.ucdavis.edu

Three things will happen, in this order:

1.  **The first time only**, it asks something like *"Are you sure you want to continue connecting?"* — type `yes` and press Enter.
2.  It asks for your password. **Nothing appears as you type — no dots, no stars.** That is normal and does not mean it isn't working. Type it and press Enter.
3.  You get a new prompt ending in `$`. You are now on Hive.

Check where you are:

    # pwd = "print working directory" — shows where you currently are
    pwd
    /home/proteomics-class-NN        <- printed by the computer, not typed by you   (with your own number)

That's your own private folder on Hive, called your **home directory**. Everything you make goes here. Nobody else can see it.

> [!WARNING]
>
> **Password rejected?** The most common causes are a typo (you can't see it, so retype carefully), or copying an extra space at the end. Check you used *your* username, not the example. If it still fails, tell your instructor — don't keep retrying, repeated failures can lock the account.
>

## 3. Nine Linux commands — the whole survival kit

You genuinely don't need more than these. Try each one now.

| Command        | What it does                                                 |
|----------------|--------------------------------------------------------------|
| `pwd`          | Shows where you are                                          |
| `ls`           | Lists what's here                                            |
| `ls -la`       | Lists with sizes and dates                                   |
| `cd somewhere` | Moves you into a folder ("change directory")                 |
| `cd ~`         | Goes back to your home directory. `~` always means "my home" |
| `cat file`     | Prints a small text file to the screen                       |
| `less file`    | Views a big file. Press `q` to quit                          |
| `mkdir name`   | Makes a new folder                                           |
| `exit`         | Logs out of Hive                                             |

### Three habits that will save you the most typing

-   **Tab completion.** Start typing a name and press `Tab` — it finishes it for you. This matters enormously here, because our data files have names like `04Aug2026_AB-G_bead_100spd_DIA_S3-E2_1_23351.d`. Type `04Aug2026_AB-G_be` then Tab. Never type a filename in full.
-   **Up arrow** brings back your previous command, so you can fix a typo instead of retyping the whole line.
-   **`Ctrl C`** stops whatever is currently running and gives you your prompt back. It is safe — you'll use it later to stop *watching* a job without stopping the job itself.

### What a "path" is

A path is an address, with `/` between the parts, read left to right:

    /quobyte/proteomics-grp/2026_shortcourse_data
     └─ top     └─ our group's  └─ this course's
        level      storage         folder

A path starting with `/` works from anywhere, so you can always paste a full path and it will be understood. That's why every path in this handout starts with a slash.

## 4. Start Claude Code

This is the only command you need. Copy the whole line:

    bash /quobyte/proteomics-grp/2026_shortcourse_data/start-claude.sh

The **first** time you run it, it installs Claude Code into your home directory — about a minute — and then starts it. You don't need to run it twice.

It pauses for a few seconds on *“Getting you a compute node”*. That is normal and it matters — see the box below. Then you'll see a green line naming the machine you landed on:

    On compute node hive-dc-7-5-46, job 20000944 — not the login node.

You'll know it worked when the screen changes and you can type a question in plain English.

> [!TIP]
>
> **Why it fetches you a machine of your own.** When you log in, you land on a *login node* shared by the whole campus. It is for typing commands and sending work off — not for doing work. But Claude runs commands on your behalf, and those run wherever Claude is running. Thirty-one of us doing that on the login node at once would slow it to a crawl and get the class accounts suspended.  
>
> So the start-up command borrows you a small slice of a real compute node (4 cores, 16 GB, up to 8 hours) and starts Claude *there*. You don't have to do anything — it happens every time. Big searches are still sent off as their own separate jobs on top of this.
>

> [!TIP]
>
> **Next time, just type this:**
>
> ```
> claude-course
> ```
>
> The first run sets that shortcut up for you. If it doesn't work yet, open a fresh terminal — or run `source ~/.bashrc` once.
>

> [!NOTE]
>
> **"Which folder should I be in when I start it?"** Your home directory — and the command above puts you there automatically, wherever you happened to be. You never need to `cd` anywhere first.  
>
> Claude Code writes its work into whatever folder it started in, so starting at home keeps your results in your own space and keeps 30 people from tripping over each other. You can still *read* the shared data from there, because every data path in this handout starts with `/quobyte/` — a full address that works from anywhere.
>

> [!NOTE]
>
> **It starts up saying “Sonnet 5 at medium effort” — that is deliberate.** The whole class shares one budget, and those two settings are what keep 31 people inside it.  
>
> **Model** is which Claude answers you; **effort** is how long it thinks before replying. A bigger model and harder thinking cost several times more per question and buy you nothing here — the proteomics knowledge is the same either way, and the pipeline does the real work. Turning either up mostly spends the class's money faster.  
>
> You never need to set them: the start-up command does it every time. Just don't change them with `/model` or `/effort` — and if you already have, `/exit` and start again to get the right settings back.
>

Three things to know while you're in Claude Code:

-   `/model` shows which model you're on, and `/effort` how hard it thinks. **Both are already set for you — leave them alone.**
-   `/exit` leaves Claude Code and returns you to the normal prompt.
-   Ask it anything in plain English — including *"what does this error mean?"* Explaining things is one of the things it's best at, so use it as your first port of call.

> [!WARNING]
>
> **If it says the course key is missing**, that is not something you can fix — it's a setup step on the instructor's side. Tell your instructor: *"start-claude.sh says the course key is missing."*
>

## 5. Install the proteomics skill

This teaches Claude Code how to do proteomics properly — which search engine to use, the right settings for our instrument, and how to run jobs correctly on the cluster.

**Inside Claude Code** (not at the normal prompt), type these two lines, one at a time:

    /plugin marketplace add bsphinney/DE-LIMP
    /plugin install ucdavis-proteomics-core-pipeline

You only ever do this once. Check it's there by typing `/plugin`.

> [!NOTE]
>
> **Why two commands?** The first adds the *catalogue* — it tells Claude Code where to look. The second installs the one skill we use from it. If it asks where to install, choose **user**, so it works in every folder rather than only the one you happen to be in.  
>
> **Installed it on an earlier day?** Run `/plugin install ucdavis-proteomics-core-pipeline` again to pick up the latest version. You want **1.2.0 or newer** — older copies could quietly pick a different search engine from the one you asked for.
>

## 6. Find the course data

The data lives in our group storage, shared by the whole class.

> [!WARNING]
>
> **Treat the data folders as look-only.** You are in the group that owns them, so the system will *let* you change or delete files there — but these are the only copies, shared by everyone. Read from them; never write into them. All your own work goes in your home directory, which is private to you and where Claude Code starts by default.
>

`/exit` Claude Code for a moment so you're at the normal `$` prompt, then look:

    # the main course dataset — mouse samples, three preparation methods
    ls /quobyte/proteomics-grp/2026_shortcourse_data/2026_data | head

You should see a long list of names ending in `.d`. Each `.d` is **one mass-spec run** — it looks like a file but is actually a folder full of instrument data.

Count them, and see the three preparation methods:

    # how many runs are there?
    ls -d /quobyte/proteomics-grp/2026_shortcourse_data/2026_data/*.d | wc -l
    136        <- printed by the computer, not typed by you

    # just the bead-prep runs
    ls -d /quobyte/proteomics-grp/2026_shortcourse_data/2026_data/*bead*.d | wc -l
    34        <- printed by the computer, not typed by you

Reading a filename — they all follow the same pattern:

    04Aug2026_AB-G_bead_100spd_DIA_S3-E2_1_23351.d
        │       │     │     │    │    │      │
       date   whose  prep  speed  │  well   run ID
              sample method       acquisition

There are **four** prep methods this year: **bead** (34 runs), **urea** (34), **s-trap** (32) and **UE** (22). The remaining 14 are **blnk** — blank injections. Leave the blanks out of any comparison; they are not samples. There are no HeLa QC runs in this folder — use `hela` for that.

### The other folders worth knowing

| What                           | Where                                                                      |
|--------------------------------|----------------------------------------------------------------------------|
| Main course data (136 runs)    | `/quobyte/proteomics-grp/2026_shortcourse_data/2026_data`                  |
| Practice HeLa file (**human**) | `/quobyte/proteomics-grp/2026_shortcourse_data/hela`                       |
| These handouts                 | `/quobyte/proteomics-grp/2026_shortcourse_data/handouts`                   |
| Worked example analyses        | `/quobyte/proteomics-grp/2026_shortcourse_data/prep_method_comparison_3x3` |

> [!NOTE]
>
> **Always save your own results in your home directory** (`~`). Every example below does this — notice each one says "put the results in my home directory".
>

## 7. Run your first search

Start Claude Code again (`claude-course`) and ask in plain English. You can paste this whole thing:

    Search this timsTOF DIA file with DIA-NN and tell me how many
    proteins were identified. The species is mouse. Put all the
    results in my home directory.

    /quobyte/proteomics-grp/2026_shortcourse_data/2026_data/04Aug2026_AB-G_bead_100spd_DIA_S3-E2_1_23351.d

Claude will work out that this is DIA data from a timsTOF, pick the right validated settings, fetch the mouse protein database, write a cluster job, submit it, and watch it until it finishes.

**It will ask you to confirm before it starts.** Read that summary — it tells you what it's about to do. Then say yes.

### When you're ready for a real comparison

The interesting question in this dataset is whether the three preparation methods differ. Try:

    Compare three bead-prep and three urea-prep runs from
    /quobyte/proteomics-grp/2026_shortcourse_data/2026_data
    The species is mouse. Which proteins differ between the two methods?

> [!WARNING]
>
> **Always say which species.** It cannot be worked out from the file, and the wrong species doesn't produce an error — it just quietly finds far fewer proteins.
>
> -   Anything in `2026_data` (the 136 course runs) is **mouse**.
> -   The file in `hela` is **human**.
>

## 8. Watching your job

Big searches don't run in your terminal — they get sent to the cluster's shared computers as a **job**. Submitting prints a job number like `19527064`.

    # what are my jobs doing?  PD = waiting, R = running
    squeue -u $USER

    # what happened to a job that finished?
    sacct -j 19527064 --format=JobID,State,Elapsed

    # watch the output appear as it's written (Ctrl C to stop watching)
    tail -f ~/my_search.log

    # cancel a job you no longer want
    scancel 19527064

> [!TIP]
>
> **You can close your laptop and go home.** Your job keeps running on the cluster without you. Log back in tomorrow, start Claude Code, and say *"resume this analysis"* — it reads its own notes and carries on from where it got to.
>

> [!WARNING]
>
> **Never run a big search directly at the `$` prompt.** Claude Code already runs on a compute node, so you are not on the login node — but the slice you were given is only 4 cores and it ends after 8 hours. A real search wants 32 cores and must outlive your terminal, so it goes off as its own job. Claude does this for you automatically; this matters only if you start writing your own commands.  
>
> And if you ever open a second terminal to Hive by hand, that one *is* on the login node. Don't run searches there.
>

## 9. What a good result looks like

So you can tell success from a silent failure. Both rows below are real runs on these accounts, on the same HeLa quality-control file. Which number you should expect depends on how you searched — compare like with like:

|                                            |                                                    |
|--------------------------------------------|----------------------------------------------------|
| Searching with the ready-made library      | 4,733 proteins · 39,068 peptides · about 3 minutes |
| Searching without one (built from scratch) | 4,466 proteins · 35,952 peptides · about 6 minutes |

> [!TIP]
>
> **Ask for the report — it is the part worth reading.** Say *“make me the HTML report”* and you get one page holding the quality-control panels, the figures and the write-up together. The QC panels come first on purpose: they tell you whether to believe everything below them. Step 10 shows how to copy it to your own computer.
>

Your main results file is `report.parquet`. The one most people actually want is `report.pg_matrix.tsv` — a table of proteins against samples. Ask Claude Code to explain any file it produces.

> [!TIP]
>
> **Sanity-check your own numbers.** If a mouse sample gives you a few hundred proteins instead of a few thousand, something went wrong — often the wrong species. Ask Claude Code to look at the log and QC summary with you. Getting a number is easy; knowing whether to believe it is the real skill this course is teaching.
>

## 10. Get your results onto your own computer

Your results live on Hive. Copy them to your own laptop so you can read them properly — and so you still have them after the course ends.

**First, on Hive, ask Claude Code:**

    make me the HTML report, then zip up my session folder

The report is a single file holding the quality-control panels, the figures and the write-up all together. It opens by double-clicking in any browser — no Word, nothing to install.

> [!TIP]
>
> **The easy way: double-click `Get My Results.cmd`** — your instructor gives you two files with this handout: `Get My Results.cmd` and `Get-My-Results.ps1`. **Save both into the same folder** (Downloads is fine), then double-click the `.cmd` one.  
>
> Pick your number from the class list. **That is the only thing you do** — there is no password to type. Your files land in a **Proteomics-Results** folder on your Desktop, which it opens for you.  
>
> The very first time, it spends a few seconds fetching a small file-transfer helper. That is normal, it only happens once, and nothing is installed on your computer.
>

> [!WARNING]
>
> **“…is not digitally signed. You cannot run this script”?** You double-clicked the `.ps1` instead of the `.cmd`. Windows blocks downloaded PowerShell scripts, which is exactly what the `.cmd` is there to handle — use that one.  
>
> **Still asking for a password?** You have an older copy of `Get-My-Results.ps1` in that folder. Delete it, save the one your instructor gave you in its place, and run the `.cmd` again.
>

**Already have SmarTTY open?** It can fetch files by itself — SmarTTY supports SCP downloads and can show your Hive folders in a Windows-style browser. Look for **SCP** in its menus. Your files are under `sessions` in your home folder.

**Using PowerShell to reach Hive? Do it this way.** You already have everything you need — Windows ships with `scp`, the same way it ships with `ssh`. Nothing to download.

**Step 1 — in Claude, on Hive**, ask it to package the run:

    (type this to Claude, not at the $ prompt)
    zip up my results for me

It writes a single `.zip` into your `sessions` folder with the report, the tables and the settings inside. One file is far easier to carry home than a tree of them.

**Step 2 — open a *new* PowerShell window** on your own computer. Not the one logged into Hive — a fresh one, so you are on your own machine. Then:

    # go to your Desktop so the files are easy to find
    cd $HOME\Desktop

    # fetch every zip you have made (use YOUR number)
    scp "proteomics-class-NN@hive.hpc.ucdavis.edu:sessions/*.zip" .

It asks for your Hive password — the same one you log in with, and again nothing appears as you type. The zips land on your Desktop. Right-click one and choose **Extract All**.

> [!WARNING]
>
> **Don't try to copy the whole folder.** It is tempting to run `scp -r` on your `sessions` folder, but the run folders point at the shared course data, and `scp -r` follows those pointers — one folder that looks like 90 MB comes down as nearly a gigabyte of raw data you already have. Fetch the `.zip` instead. If you want loose files rather than a zip, ask Claude to *“copy just my reports into a folder called reports”* and then run `scp "proteomics-class-NN@hive.hpc.ucdavis.edu:reports/*" .`
>

> [!WARNING]
>
> **If you type it by hand, three things break it — all avoidable.**
>
> -   **It must be one line.** Wrapping on screen is fine; pressing Enter in the middle is not. A command missing its ending is the most common failure here.
> -   **Keep the dot at the end.** That lone `.` means “put it right here”. Without it, scp has nowhere to put the file and only prints its own help.
> -   **Swap in your own number.** If a command still contains `NN`, it hasn't been filled in yet and Hive will refuse it. Put your own two-digit number there, or ask Claude Code to write the line out with it already filled in.
>

> [!NOTE]
>
> **Why there's no long `/home/...` path.** After the colon, scp already starts in your Hive home folder, so `sessions/*.zip` is enough. Shorter command, less to mistype.
>

> [!WARNING]
>
> **Do this before the course ends.** These accounts are temporary and get switched off afterwards. Anything you have not copied to your own computer goes away with them.
>

## 11. If something goes wrong

| You see                                   | What it means / what to do                                                                                                                                       |
|-------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Permission denied, please try again`     | Wrong password, or you typed the example username. Retype carefully — you won't see the characters.                                                              |
| `command not found: claude`               | Run the long `bash /quobyte/...start-claude.sh` line again, or open a new terminal.                                                                              |
| `the course key is missing`               | Instructor-side setup. Tell your instructor — you can't fix this.                                                                                                |
| `No such file or directory`               | A typo in a path. Use `Tab` to complete names instead of typing them.                                                                                            |
| `That session ended early`                | The cluster took your compute node back — it happens occasionally and costs you nothing. Type `claude-course` again and say *"carry on from where we left off"*. |
| It sits on *"Getting you a compute node"* | Normally a few seconds. If it lasts more than a couple of minutes the cluster is busy — wait, or press `Ctrl C` and try again shortly.                           |
| “you already have a Claude session”       | You closed a window without typing `/exit`, so it's still holding a machine. Run the `scancel` command it prints.                                                |
| Terminal frozen / nothing responds        | Press `Ctrl C`. If your connection dropped, just log in again — your jobs kept running.                                                                          |
| A billing or limit error                  | The class may have reached the shared budget. Tell your instructor.                                                                                              |
| Only a few hundred proteins found         | Usually the wrong species. Say "the species is mouse" and run it again.                                                                                          |

> [!WARNING]
>
> **Two shared budgets — please be considerate.**
>
> -   **Claude Code** is one shared allowance for the whole class. The start-up command already puts you on the right model and effort level — **don't raise either** (`/model`, `/effort`): a bigger model or harder thinking costs several times more per question and gives you no better proteomics. Ask Claude to read result files *from disk* rather than pasting big tables into the chat, and `/exit` when you're done.
> -   **The cluster** is shared with the whole campus. Don't submit ten jobs to see what sticks — one well-described request beats ten guesses.
>

Hive user guide: [hpc.ucdavis.edu](https://hpc.ucdavis.edu/) · Claude Code docs: [code.claude.com/docs](https://code.claude.com/docs/en/quickstart)  
UC Davis Proteomics Core — Short Course 2026. Stuck on something not listed here? Ask your instructor or ask Claude Code itself — explaining errors is one of the things it's best at.
