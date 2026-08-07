# Claude Code for students — instructor setup

Your students are on **Hive (Linux, terminal/SSH)** or **Windows boxes**. The **"Student Setup"** folder has a launcher for each. Do the one setup step below, then get the folder to your students.

## Step 1 (once): put your course key in `api-key.txt`

Open **`Student Setup/api-key.txt`**, delete the placeholder `PASTE-YOUR-COURSE-KEY-HERE`, and paste your course key (the `sk-ant-api03-…` you created as `proteomics-course-2026`). Save. The file should contain the key and nothing else. Every launcher reads the key from this file.

## Step 2: get the "Student Setup" folder to your students

**Windows students:** send them the `Student Setup` folder (zip it: right-click → Compress → email or post to Canvas). Send **only that folder** — it has the launchers, the key, and the handout, and deliberately excludes your `roster.csv` (attendee emails) and instructor notes.

**Hive students:** the easiest path on a shared cluster is to drop the `Student Setup` folder into a **shared course directory on Hive that all students can read** (e.g., a class/scratch share). Then every student runs it straight from there — no per-person file copying. If there's no shared spot, students can `scp` the folder into their Hive home directory.

---

## What students do

### On Windows (double-click)
1. Unzip the folder.
2. Double-click **`Start Claude Code (Windows).bat`**.
3. The first double-click **installs** Claude Code (~1 min). When prompted, **double-click once more** to start it.
4. Type questions in the window. Stay on **Sonnet 5** (`/model` to check). `/exit` when done.

### On Hive (terminal / SSH)
1. `cd` into the `Student Setup` folder (the shared copy, or their own copy).
2. Run:
   ```
   bash start-claude-code.sh
   ```
3. The first run **installs** Claude Code into their home dir. Then run the **same command again** to start it.
4. Type questions in the terminal. Stay on **Sonnet 5** (`/model` to check). `/exit` when done.

*(There's also a `Start Claude Code (Mac).command` in the folder for anyone on a Mac laptop — double-click it; first time, right-click → Open to clear the security prompt.)*

---

## Reminders

- Everyone shares the one key and the **$500 monthly cap** — the class can never spend past $500.
- Keeping students on **Sonnet 5** is what keeps you comfortably under budget.
- On Hive, students just need outbound internet to reach `claude.ai` / `api.anthropic.com`. Home-directory installs need no admin.
- **Shutdown after the course:** in the Console, **Settings → API keys → `proteomics-course-2026` → Delete.** That instantly cuts off access for everyone.
