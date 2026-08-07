# Proteomics Short Course 2026 — Claude Code access for students

You are helping the instructor (Brett, UC Davis) give **31 students temporary Claude Code access**
for a proteomics data-analysis short course. Everything you need is in this folder. Read this whole
file, then help drive the setup. Prefer doing the automatable parts yourself and coaching the
instructor through the few steps that can only be done in the Console UI.

## The plan (already decided)

- **One workspace + one API key per student**, each with its own spend cap.
- **Per-student cap: $15** (31 × $15 = $465, just under the org backstop).
- **Organization-wide spend cap: $500** — the hard ceiling; it always wins.
- **Default model: Sonnet** (not Opus). Proteomics domain knowledge is identical across models;
  Sonnet keeps the class comfortably under budget. Opus would risk blowing the $500 cap.
- Aiming to stay **under $500 total** for the term.

## Files in this folder

- `instructor-setup-guide.md` — the full human guide. Source of truth for the steps.
- `provision.py` — automates the workspace **create** and **archive** steps (stdlib only, no installs).
- `roster.csv` — the tracking sheet: `student_name, student_email, workspace_name, workspace_id, api_key, cap_usd, notes`.
- `student-handout.html` — the one-pager to give each student with their key.

## What you CAN automate (do these for the instructor)

Using `provision.py` (needs an Admin key: `export ANTHROPIC_ADMIN_KEY=sk-ant-admin-...`):

- **Preview then create the workspaces:**
  `python3 provision.py --create --dry-run` then `python3 provision.py --create`
  (writes each new `workspace_id` back into `roster.csv`).
- **List workspaces:** `python3 provision.py --list`
- **Tear everything down at term end:**
  `python3 provision.py --archive-all --dry-run` then `python3 provision.py --archive-all`
  (archiving disables the keys, ending access).

You can also help edit `roster.csv` — add the 31 real students, derive workspace names, sanity-check
rows, and flag duplicates or blanks.

## What you CANNOT do — the instructor must do these in the Console UI (console.anthropic.com)

The Anthropic Admin API has **no endpoint** for these, so never claim to have done them:

1. **Create the API key** inside each workspace (the `sk-ant-…` secret is shown only once — the
   instructor copies it into `roster.csv`).
2. **Set each workspace's $15 spend cap** (Settings → Limits → the workspace).
3. **Set the $500 organization cap** (Settings → Limits → Spend limits).

For these, give the instructor a tight, numbered checklist and the exact Console menu paths, then wait.

## Suggested flow when the instructor opens this folder

1. Confirm the org exists and the **$500 org cap** is set (ask; you can't verify it via API here).
2. Make sure `roster.csv` has the **real 31 students** (offer to help fill it; remove the EXAMPLE row).
3. Check `ANTHROPIC_ADMIN_KEY` is set. If not, walk them through creating an Admin key (org owner only).
4. Run `provision.py --create --dry-run`, show the plan, then `--create` once they approve.
5. Hand them the per-workspace **key + cap** checklist for the Console UI, and have them paste each
   `sk-ant-…` key into `roster.csv` as they go.
6. Help them distribute each student **their own** key privately (e.g., Canvas private comment) plus
   `student-handout.html`.
7. Mid-term: if a student maxes out, remind them to raise that one workspace's cap in the Console
   (org cap still protects the total).
8. Term end: run `provision.py --archive-all` (dry-run first).

## Guardrails

- **Never print or echo full `sk-ant-…` secrets** to the terminal or logs. Mask them (show last 4).
- **Always `--dry-run` first** for create and archive; get explicit approval before the real run.
- `roster.csv` contains live API keys — treat it as a secret. Warn the instructor not to commit it to
  any public repo. (Consider adding `roster.csv` to `.gitignore` if this folder is a git repo.)
- Don't switch students to Opus or raise caps without the instructor asking.
- These estimates and prices change — if pricing matters, check current rates rather than guessing.
