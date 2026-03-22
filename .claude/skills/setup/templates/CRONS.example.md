# Scheduled Cron Jobs

Registered on every boot via CronCreate. Heartbeat is excluded (handled by boot skill directly).

Copy this file to `CRONS.md` and customize for your own jobs.

## Active Jobs

| ID | Schedule | Description | Prompt |
|----|----------|-------------|--------|
| example | `*/5 * * * *` | Example: fetch data every 5 minutes | Replace with your prompt here |

## Inactive Jobs

<!-- Move entries here to disable without deleting -->

---

## Deduplication (recommended for API calls)

Cron triggers can fire multiple times in the same interval due to scheduler jitter.
To prevent duplicate API calls and Telegram messages, wrap your bash command with a lock file check:

```bash
LOCK=/tmp/ccc-<job-id>; NOW=$(date +%s); if [ -f "$LOCK" ] && [ $((NOW - $(cat "$LOCK"))) -lt <interval_seconds * 0.75> ]; then echo "SKIP"; else echo $NOW > "$LOCK"; <your command here>; fi
```

- Replace `<job-id>` with a unique name (e.g. `ccc-btc`, `ccc-weather`)
- Replace `<interval_seconds * 0.75>` with ~75% of your interval in seconds
  - Every 2 min (`*/2`) → 90s
  - Every 5 min (`*/5`) → 225s
  - Every 10 min (`*/10`) → 450s
- In your prompt: "if output is `SKIP`, stop here and do nothing"

### Example prompt using dedup

```
Run this bash command: `LOCK=/tmp/ccc-myapi; NOW=$(date +%s); if [ -f "$LOCK" ] && [ $((NOW - $(cat "$LOCK"))) -lt 90 ]; then echo "SKIP"; else echo $NOW > "$LOCK"; curl -s "https://api.example.com/data"; fi` — if output is "SKIP", stop here and do nothing. Otherwise parse the result and send to Telegram chat_id YOUR_CHAT_ID.
```
