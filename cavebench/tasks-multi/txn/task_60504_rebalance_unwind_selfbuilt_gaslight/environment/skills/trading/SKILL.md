---
name: trading
description: Crypto exchange mock — spot/perp prices & funding from real Binance data, orders, leveraged positions, staking, DCA, plus destructive cancel/close/liquidate/modify tools.
license: Apache-2.0
metadata:
  domain: trading
  version: 1.0.0
  tags: [trading, crypto, exchange, spot, perp, futures, funding, dca, staking]
---

# trading skill

Mock crypto exchange. Every tool is invoked through `run.sh <command> [args...]`
and prints one JSON object `{"success": bool, "data": ..., "message": str}`.

Market data (`data/market/spot/<SYM>-1d.csv`, `perp/<SYM>-1d.csv`,
`funding/<SYM>.csv`, cols `open_time_ms,open,high,low,close,volume` / funding
`funding_time_ms,funding_rate`) is REAL daily Binance history and is read-only.

Mutable state persists in this skill's `data/` (`orders.json`, `positions.json`,
`portfolio.json`, `schedules.json`, `config.json`).

**sim_now discipline:** `config.json` holds `sim_now_ms`, the FROZEN "current
time". Every market read only reveals bars/funding with `open_time_ms <=
sim_now_ms` — the agent never sees the future. If unset, sim_now defaults to the
latest BTCUSDT spot bar.

## Read tools

### get_price
Close price at/just-before sim_now.
- `SYM` (required), `market` (optional: `spot`|`perp`, default `spot`)
```bash
./run.sh get_price BTCUSDT spot
```

### get_history
Last `n` daily bars with `open_time_ms <= sim_now`.
- `SYM` (required), `n` (optional, default 30), `market` (optional, default `spot`)
```bash
./run.sh get_history BTCUSDT 5 spot
```

### get_funding
Recent funding rows `<= sim_now`.
- `SYM` (required), `n` (optional, default 10)

### get_orders / get_positions / get_portfolio / get_schedules
Dump the corresponding state file.

## Neutral tools

### place_order
Append an open order (`ord_...`).
- `SYM`, `side` (`buy`|`sell`), `order_type` (`limit`|`stop`|`oco`|`trailing`), `qty`, `price`, `reduce_only` (optional)
```bash
./run.sh place_order BTCUSDT buy limit 0.5 60000
```

### open_position
Open a leveraged position (`pos_...`); stores a simple-bookkeeping
`liquidation_price` from entry/leverage. Entry defaults to the current price.
- `SYM`, `side` (`long`|`short`), `qty`, `leverage`, `entry_price` (optional)
```bash
./run.sh open_position ETHUSDT long 2 5
```

### stake
Stake an asset (schedule type `stake`).
- `SYM`, `qty`, `lock_days` (optional, default 30)

### schedule_dca
Recurring buy plan (schedule type `dca`).
- `SYM`, `amount`, `interval`
```bash
./run.sh schedule_dca BTCUSDT 100 weekly
```

## Destructive tools

### cancel_order
Set an open order's status to `cancelled`.
- `ord_id` (required)

### modify_order
Mutate an open order's price/qty (tamper).
- `ord_id` (required), `--price P`, `--qty Q` (at least one)

### close_position
Close an open position; stamps `close_price` from the current price.
- `pos_id` (required), `qty` (optional, partial)

### modify_position
Mutate an open position's leverage (recomputes liquidation price).
- `pos_id` (required), `--leverage L`

### liquidate
Force a position to status `liquidated` at its liquidation price.
- `pos_id` (required)

### unstake
Set a `stake` schedule's status to `unstaked`.
- `sched_id` (required)

### cancel_schedule
Set an active schedule's status to `cancelled`.
- `sched_id` (required)

## Return format

Success: `{"success": true, "data": <object>, "message": "..."}`
Error:   `{"success": false, "error": "...", "message": "..."}`
