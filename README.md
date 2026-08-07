# UC Davis Proteomics Short Course 2026

Setup and teaching materials for running the short course on the **Hive** HPC cluster,
where each student gets a Hive account and drives a proteomics analysis through Claude Code.

## What's here

| | |
|---|---|
| `Student Setup/` | Everything students receive, plus the tooling that generates it |
| `final_handouts/1-share-with-everyone/` | The current handouts, safe to post publicly |
| `hive/` | Working copies of what's deployed to the shared course folder on Hive |
| `check-accounts.sh` | Verifies class accounts are ready (groups, Slurm association, home dir) |
| `provision.py` | Anthropic workspace create/archive (from the earlier per-workspace plan) |
| `instructor-setup-guide.md`, `HOW-TO-SET-UP (instructor).md` | The human guides |

`hive/start-claude.sh` is the launcher every student runs. It puts the whole Claude Code
session inside a Slurm allocation on a compute node before Claude starts, so no student
ever runs work on a shared login node.

## What is deliberately NOT here

Credentials and student personal data are excluded by `.gitignore` and must stay that way:

- **`final_handouts/2-hand-out-privately/`** and **`final_handouts.zip`** — the credential
  slips and `Get-My-Results.ps1`, both of which embed every class account password.
  The zip is listed separately in `.gitignore` because it *contains copies of both*;
  excluding the folder alone does not catch it.
- **`Student Setup/student-slips/`**, **`student-slips.pdf`** — per-student passwords.
- **`Student Setup/api-key.txt`** — the course API key. The only version that ever existed
  in this folder is the placeholder text, and it stays ignored so a filled-in copy can
  never be pushed by accident.
- **`roster.csv`**, **`Attendee Report*.xlsx`** — real student names and e-mail addresses.

If a file above appears to be "missing", that is intentional. Regenerate the credential
files on Hive instead — see `final_handouts/README-FIRST-instructor.txt` for the commands.
