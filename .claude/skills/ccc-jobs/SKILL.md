---
name: ccc-jobs
description: Manage scheduled jobs — add, remove, pause, resume, edit, list. Live-syncs JOBS.yaml with CronCreate/CronDelete.
---

# Jobs Skill

Manage scheduled jobs defined in `JOBS.yaml`. All changes are written to YAML **and** live-synced with CronCreate/CronDelete immediately.

## Commands

| Command | Action |
|---------|--------|
| `/ccc-jobs list` | Show all jobs with status |
| `/ccc-jobs add` | Add a new job interactively |
| `/ccc-jobs remove <id>` | Delete a job permanently |
| `/ccc-jobs pause <id>` | Set `active: false` and unregister from cron |
| `/ccc-jobs resume <id>` | Set `active: true` and register with cron |
| `/ccc-jobs edit <id>` | Modify a job interactively |

Args are passed via the Skill tool's `args` parameter (e.g., `skill: "ccc-jobs", args: "pause btc-price"`).

## Steps

### Parse command

Extract the subcommand and optional job ID from args:
- No args or `list` → **list**
- `add` → **add**
- `remove <id>` → **remove**
- `pause <id>` → **pause**
- `resume <id>` → **resume**
- `edit <id>` → **edit**

### Read JOBS.yaml

Read `JOBS.yaml` from the project root. Parse the YAML structure. Each job has:

```yaml
jobs:
  <id>:
    schedule: "<cron expression>"
    description: <short description>
    active: true|false
    prompt: |
      <prompt text>
```

### Execute subcommand

#### list

Display all jobs in a table format:

```
| ID | Schedule | Active | Description |
|----|----------|--------|-------------|
| btc-price | */10 * * * * | ✓ | BTC price from CoinGecko |
```

Also run CronList to show which jobs are currently registered in the session.

#### add

Ask the user for each field:
1. **ID** — short kebab-case identifier (e.g., `daily-report`)
2. **Schedule** — cron expression (e.g., `0 9 * * *`)
3. **Description** — one-line summary
4. **Prompt** — the prompt text (can be multi-line)

Then:
1. Write the new job entry to `JOBS.yaml` using the Edit tool
2. Run `CronCreate` with the schedule and prompt
3. Confirm to the user

#### remove

1. Verify the job ID exists in `JOBS.yaml`
2. Run `CronList` to find the matching cron job, then `CronDelete` it
3. Remove the entry from `JOBS.yaml` using the Edit tool
4. Confirm to the user

#### pause

1. Verify the job ID exists and is currently `active: true`
2. Change `active: true` to `active: false` in `JOBS.yaml`
3. Run `CronList` to find the matching cron job, then `CronDelete` it
4. Confirm to the user

#### resume

1. Verify the job ID exists and is currently `active: false`
2. Change `active: false` to `active: true` in `JOBS.yaml`
3. Run `CronCreate` with the job's schedule and prompt
4. Confirm to the user

#### edit

1. Verify the job ID exists
2. Show the current values and ask what to change
3. Update `JOBS.yaml` with the new values
4. If the job is active: `CronDelete` the old cron → `CronCreate` with updated values
5. Confirm to the user

### Matching JOBS.yaml entries to CronList

CronCreate returns a session-internal ID that differs from the JOBS.yaml job ID. To match them:
- Use CronList to list all cron jobs
- Match by the prompt text (the prompt field is unique per job)
- If no match is found, the job is not currently registered (e.g., after a session restart)

## Notes

- JOBS.yaml is the source of truth for persistent job definitions
- CronCreate/CronDelete are session-scoped (lost on session end)
- SessionStart hook registers all `active: true` jobs on every session start (background agent)
- Heartbeat is NOT managed here — it's registered separately by SessionStart hook

## Usage

```
/ccc-jobs
/ccc-jobs list
/ccc-jobs add
/ccc-jobs remove btc-price
/ccc-jobs pause btc-price
/ccc-jobs resume btc-price
/ccc-jobs edit btc-price
```
