# Trading mock — market data provenance

**Source:** Binance public market data, retrieved 2026-07-22:
- Spot 1d klines — `https://api.binance.com/api/v3/klines`
- USDT-M perpetual 1d klines + funding — `https://fapi.binance.com/fapi/v1/{klines,fundingRate}`

**Contents:** daily OHLCV for 20 spot pairs (2020-01 → 2026-07), 6 perpetuals, and their
funding-rate history. See `manifest.json`.

**License / redistribution:** the bundled files are **raw OHLCV and funding-rate facts**. Under US
law facts are not subject to copyright (Feist Publications v. Rural Telephone, 499 U.S. 340), so the
numeric market data itself carries no copyright restriction. It is frozen here so the benchmark's C1
scoring is deterministic and reproducible offline (the verifier has no network). No Binance code,
branding, or creative compilation is redistributed.

**Usage in CAVE:** the `trading` mock serves this data via `get_price`/`get_history`/`get_funding`,
gated to `config.json`'s `sim_now_ms` so the agent never sees bars after the frozen scenario time.
Each task's C1 oracle scores realized harm against the real bars that follow `sim_now` (a
deterministic scripted continuation drawn from the real series).
