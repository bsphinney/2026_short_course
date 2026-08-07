#!/usr/bin/env python3
"""
provision.py — Batch-manage Anthropic Console *workspaces* for a class.

WHAT THIS SCRIPT CAN DO (these parts of the Anthropic Admin API support automation):
  --create        Create one workspace per student listed in roster.csv,
                  and write each new workspace_id back into roster.csv.
  --archive-all   Archive every workspace whose id is in roster.csv (term-end teardown).
                  Archiving a workspace disables its keys, ending access.
  --list          List the workspaces currently in your organization.

WHAT THIS SCRIPT CANNOT DO (the Admin API has no endpoint for these; do them in the Console UI):
  * Create API keys                -> make one key inside each workspace in the Console.
  * Set per-workspace spend limits -> set each workspace's cap in the Console (Settings -> Limits).

USAGE
  export ANTHROPIC_ADMIN_KEY=sk-ant-admin-xxxxxxxx     # your Admin key (org owner/admin)
  python3 provision.py --create --dry-run              # preview, makes no changes
  python3 provision.py --create                        # create the workspaces
  python3 provision.py --list
  python3 provision.py --archive-all --dry-run         # preview teardown
  python3 provision.py --archive-all                   # archive all class workspaces

roster.csv columns (header required):
  student_name, student_email, workspace_name, workspace_id, api_key, cap_usd, notes
  - workspace_name is optional; if blank, it's derived from student_name.
  - workspace_id is filled in by --create; leave it blank for new students.

No third-party packages needed — standard library only.
"""

import argparse
import csv
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request

API_BASE = "https://api.anthropic.com"
ANTHROPIC_VERSION = "2023-06-01"
ROSTER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "roster.csv")
PAUSE_SECONDS = 0.4  # gentle pacing between API calls


def admin_key() -> str:
    key = os.environ.get("ANTHROPIC_ADMIN_KEY", "").strip()
    if not key:
        sys.exit("ERROR: set ANTHROPIC_ADMIN_KEY first, e.g.\n"
                 "  export ANTHROPIC_ADMIN_KEY=sk-ant-admin-xxxx")
    if not key.startswith("sk-ant-admin"):
        print("WARNING: your key does not start with 'sk-ant-admin'. "
              "The Admin API needs an *Admin* key, not a regular API key.", file=sys.stderr)
    return key


def api_request(method: str, path: str, body: dict | None = None) -> dict:
    url = API_BASE + path
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("x-api-key", admin_key())
    req.add_header("anthropic-version", ANTHROPIC_VERSION)
    if data is not None:
        req.add_header("content-type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        detail = e.read().decode(errors="replace")
        raise SystemExit(f"HTTP {e.code} on {method} {path}\n{detail}")
    except urllib.error.URLError as e:
        raise SystemExit(f"Network error on {method} {path}: {e}")


def slugify(name: str) -> str:
    s = re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")
    return s or "student"


def load_roster() -> tuple[list[dict], list[str]]:
    if not os.path.exists(ROSTER):
        sys.exit(f"ERROR: {ROSTER} not found.")
    with open(ROSTER, newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
        fields = reader.fieldnames or []
    return rows, fields


def save_roster(rows: list[dict], fields: list[str]) -> None:
    with open(ROSTER, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def real_rows(rows: list[dict]) -> list[dict]:
    """Skip blank rows and the EXAMPLE placeholder row."""
    out = []
    for r in rows:
        name = (r.get("student_name") or "").strip()
        if not name or name.upper().startswith("EXAMPLE"):
            continue
        out.append(r)
    return out


def cmd_create(dry_run: bool) -> None:
    rows, fields = load_roster()
    todo = real_rows(rows)
    if not todo:
        sys.exit("No students found in roster.csv (did you leave only the EXAMPLE row?).")
    created = 0
    for r in todo:
        if (r.get("workspace_id") or "").strip():
            print(f"skip  {r['student_name']}: already has workspace_id {r['workspace_id']}")
            continue
        wsname = (r.get("workspace_name") or "").strip() or f"proteomics-{slugify(r['student_name'])}"
        r["workspace_name"] = wsname
        if dry_run:
            print(f"DRY   would create workspace '{wsname}' for {r['student_name']}")
            continue
        resp = api_request("POST", "/v1/organizations/workspaces", {"name": wsname})
        r["workspace_id"] = resp.get("id", "")
        created += 1
        print(f"OK    created '{wsname}' -> {r['workspace_id']}  ({r['student_name']})")
        time.sleep(PAUSE_SECONDS)
    if not dry_run:
        save_roster(rows, fields)
        print(f"\nDone. Created {created} workspace(s). roster.csv updated with workspace_ids.")
        print("NEXT (Console UI, per workspace): create an API key + set the spend cap, "
              "then paste the key into roster.csv.")
    else:
        print("\nDry run only — nothing was created.")


def cmd_list() -> None:
    resp = api_request("GET", "/v1/organizations/workspaces?limit=100")
    for w in resp.get("data", []):
        archived = " [ARCHIVED]" if w.get("archived_at") else ""
        print(f"{w.get('id')}  {w.get('name')}{archived}")


def cmd_archive_all(dry_run: bool) -> None:
    rows, _ = load_roster()
    ids = [(r["student_name"], (r.get("workspace_id") or "").strip())
           for r in real_rows(rows) if (r.get("workspace_id") or "").strip()]
    if not ids:
        sys.exit("No workspace_ids in roster.csv to archive.")
    for name, wid in ids:
        if dry_run:
            print(f"DRY   would archive {wid}  ({name})")
            continue
        api_request("POST", f"/v1/organizations/workspaces/{wid}/archive")
        print(f"OK    archived {wid}  ({name})")
        time.sleep(PAUSE_SECONDS)
    print("\nDry run only — nothing archived." if dry_run
          else "\nDone. All listed workspaces archived; their keys are now disabled.")


def main() -> None:
    p = argparse.ArgumentParser(description="Batch-manage class workspaces in the Anthropic Console.")
    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument("--create", action="store_true", help="create a workspace per student in roster.csv")
    g.add_argument("--list", action="store_true", help="list workspaces in the org")
    g.add_argument("--archive-all", action="store_true", help="archive every workspace_id in roster.csv")
    p.add_argument("--dry-run", action="store_true", help="preview without making changes")
    args = p.parse_args()

    if args.create:
        cmd_create(args.dry_run)
    elif args.list:
        cmd_list()
    elif args.archive_all:
        cmd_archive_all(args.dry_run)


if __name__ == "__main__":
    main()
