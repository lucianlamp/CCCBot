# Scheduled Cron Jobs

Registered on every boot via CronCreate. Heartbeat is excluded (handled by boot skill directly).

## Active Jobs

| ID | Schedule | Description | Prompt |
|----|----------|-------------|--------|
| btc-price | `*/2 * * * *` | BTC price from CoinGecko | Run this bash command to get BTC price: `curl -s "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd,jpy"` then parse the JSON to extract usd and jpy values, and send to Telegram chat_id 1688027728 using the reply tool. Format: "BTC: $XX,XXX USD / ¥XX,XXX,XXX JPY" |

## Inactive Jobs

<!-- Move entries here to disable without deleting -->
