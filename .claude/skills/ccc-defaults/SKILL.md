---
name: ccc-defaults
description: CCC workspace default behaviors — always applied in this workspace
---

# CCC Default Behaviors

These rules are always applied in the CCC workspace. They override general defaults.

## HTTP Requests

**Always use `curl` via Bash, never WebFetch.**

```bash
curl -s "https://api.example.com/endpoint"
```

**Why:** WebFetch has a 15-minute cache, making it unsuitable for real-time data (prices, status, etc.). `curl` always fetches fresh data.

**WebFetch is only acceptable for:** parsing static documentation pages where caching is harmless.

## Telegram Reporting

- Acknowledge every channel message before starting work
- Run long tasks as background agents
- Report progress and completion via Telegram reply tool
