# Boot checklist

Run at session start:
- Read MEMORY.md
- Read today's and yesterday's memory/YYYY-MM-DD.md (if they exist)
- If there are in-progress tasks, report status to the user
- Read CRONS.md and register all Active Jobs via CronCreate (skip heartbeat, it's handled separately)
