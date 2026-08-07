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

