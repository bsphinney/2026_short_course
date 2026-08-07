# Claude Code for Your Class — Instructor Setup Guide (Individual Keys)

**Model chosen:** one **workspace + one API key per student**, each with its own spend cap (~$15), plus a **$500 organization-wide cap** as the hard backstop. 31 students, aiming to stay under $500 total, default model **Sonnet**.

This gives you per-student budgets (no one can drain the class), per-student usage visibility, and small blast radius if a key leaks — at the cost of a one-time manual setup of ~30–45 minutes.

---

## Read this first: what's automatable and what isn't

I checked the Anthropic Admin API against the docs so you don't hit surprises:

| Task | Can it be scripted? | How you'll actually do it |
|---|---|---|
| Create the 31 workspaces | **Yes** (Admin API) | Run the helper script `provision.py --create` |
| Create an API key in each workspace | **No** — no create endpoint exists | **Console UI**, one per workspace (secret shown once) |
| Set each workspace's spend cap | **No** for a standard org (Spend Limits API is Enterprise-only + per-user) | **Console UI**, per workspace |
| Archive all 31 workspaces at term end | **Yes** (Admin API) | Run `provision.py --archive-all` |

**Bottom line:** the script front-loads the workspace creation and handles teardown; the keys and caps are a manual Console pass. Budget ~30–45 minutes once.

---

## Step 1 — Create the Console org, billing, and the $500 backstop cap

1. Go to **https://console.anthropic.com**, sign in with your UC Davis email, and create an **organization** (e.g., "Davis – Proteomics Course").
2. **Settings → Billing:** add a payment method and buy an initial credit balance. The API is prepaid; you don't need to preload the full $500 — add credits as needed or enable auto-reload up to your limit.
3. **Settings → Limits → Spend limits:** set the **organization** limit to **$500**. This is the Start-tier default, so it should accept immediately — no tier upgrade needed. This cap is your absolute ceiling: even if individual student caps add up to more, the org cap stops all spending at $500.

## Step 2 — Pick your per-student cap

- **$15 per student** is a good start: 31 × $15 = **$465**, which sits just under the $500 org cap and leaves ~$35 of headroom to top up heavy users mid-term.
- On Sonnet, $15 comfortably covers **4+ hours** of Claude Code, so most students will finish their 3–5 hours well within budget.
- Remember: the org cap ($500) always wins. You can hand out individual caps that sum to more than $500 if you like — the org cap still guarantees you never exceed $500 in a month.

## Step 3 — (Optional, saves clicks) Batch-create the 31 workspaces

If you'd rather not click "New workspace" 31 times, use the helper script `provision.py` (companion file). It needs an **Admin API key**:

1. In the Console, go to **Settings → API keys** (or the Admin/Organization area) and create an **Admin key** (starts with `sk-ant-admin...`). You must be an organization **owner/admin** to do this.
2. Put your student names in `roster.csv` (companion template — one row per student).
3. Run:
   ```bash
   export ANTHROPIC_ADMIN_KEY=sk-ant-admin-YOUR-KEY
   python3 provision.py --create --dry-run   # preview what it will create
   python3 provision.py --create             # actually create the 31 workspaces
   ```
4. The script writes each workspace's ID back into `roster.csv` so you have a clean record.

Prefer to skip the script? Just create each workspace by hand in **Settings → Workspaces → Create Workspace** as you go through Step 4.

## Step 4 — Create one key + one cap per student (Console UI)

For each student (whether the workspace already exists from Step 3, or you make it now):

1. Open the student's **workspace**.
2. **Create Key** inside that workspace. Name it to match the student (e.g., "jdoe"). **Copy the `sk-ant-…` secret immediately** — it's shown only once. Paste it into your roster.
3. In the same workspace, open **Limits** and set the **workspace spend limit to $15** (your Step 2 number).
4. Record it in `roster.csv`: student → workspace → key → cap.

Tip: get into a rhythm — workspace, key, cap, next. ~1–2 minutes each.

## Step 5 — Distribute each student their own key

Give each student **only their own** key, through a private channel:

- Canvas: paste into a private gradebook comment, or email each student individually.
- Never post keys in a shared/public place.

Hand out the **student handout** (companion file) with the key. It already tells them to stay on the Sonnet model to conserve budget.

## Step 6 — When a student maxes out, raise their cap

This is the payoff of individual keys — you can top up one student without touching anyone else:

1. **Settings → Limits** (or the student's workspace) → find their workspace → **Change Limit**.
2. Raise it, e.g., $15 → $25. It takes effect immediately; their key works again as soon as the new ceiling clears their current spend.
3. Keep an eye on the running class total against the $500 org cap. As long as the total is under $500, you have room to be generous to the few who need it.
4. Note: because spend resets monthly (00:00 UTC on the 1st), a student who maxes out late in a month gets a fresh allowance at month rollover — sometimes "wait for the reset" is the answer instead of a raise.

## Step 7 — Monitor during the term

**Console → Usage / Cost** shows spend per workspace, so with individual workspaces you can see exactly who's using what. Check weekly. Set a billing alert (Settings → Billing/Limits) at ~$375 so you get warned before approaching the $500 ceiling.

## Step 8 — Tear it all down at term end

1. Revoke keys and/or archive every workspace. To do it in one shot:
   ```bash
   python3 provision.py --archive-all --dry-run   # preview
   python3 provision.py --archive-all             # archive all class workspaces
   ```
   Archiving a workspace disables its key, so access ends immediately for everyone.
2. Turn off auto-reload if you enabled it, and consider removing the payment method.

---

## Cost & model reminder (proteomics)

- **Default students to Sonnet.** Both Sonnet and Opus have the same proteomics domain knowledge; Opus only adds coding/reasoning depth that coursework rarely needs, at ~2.5× the price. Sonnet 5 (~$2/$10 per M tokens, rising to $3/$15 on Sep 1, 2026) keeps the class comfortably under $500. Opus 4.8 ($5/$25) would run ~$400–$1,500 for the class and likely blow the cap.
- **Have Claude Code read data files from disk, not paste them into chat.** Proteomics tables (protein groups, peptides) are huge; scripting against files on disk keeps token costs down and is better practice.
- With individual $15 caps on Sonnet, realistic total for 31 students × 3–5 hrs lands well under $500.

---

*Console: https://console.anthropic.com · Limits: https://platform.claude.com/settings/limits · Admin API: https://platform.claude.com/docs/en/api/administration-api*
