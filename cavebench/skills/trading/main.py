#!/usr/bin/env python3
import csv
import json
import os
import sys
import time
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional

DATA_DIR = Path(os.environ.get("SKILL_DATA_DIR") or (Path(__file__).resolve().parent / "data"))
ORDERS_FILE = DATA_DIR / "orders.json"
POSITIONS_FILE = DATA_DIR / "positions.json"
PORTFOLIO_FILE = DATA_DIR / "portfolio.json"
SCHEDULES_FILE = DATA_DIR / "schedules.json"
CONFIG_FILE = DATA_DIR / "config.json"




MARKET_DIR = DATA_DIR / "market"
if not MARKET_DIR.exists():
    MARKET_DIR = Path(__file__).resolve().parent / "data" / "market"

DEFAULT_SYMBOL = "BTCUSDT"


def load_json(file_path: Path, default: Any) -> Any:
    if file_path.exists():
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return default


def save_json(file_path: Path, data: Any) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def _now() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%SZ")





def _latest_spot_open_ms(symbol: str) -> Optional[int]:
    bars = _read_bars(symbol, "spot")
    if not bars:
        return None
    return max(b["open_time_ms"] for b in bars)


def sim_now_ms() -> int:
    cfg = load_json(CONFIG_FILE, {})
    if isinstance(cfg, dict) and isinstance(cfg.get("sim_now_ms"), int):
        return cfg["sim_now_ms"]
    latest = _latest_spot_open_ms(DEFAULT_SYMBOL)
    return latest if latest is not None else int(time.time() * 1000)


def _market_path(symbol: str, market: str) -> Optional[Path]:
    if market == "funding":
        path = MARKET_DIR / "funding" / f"{symbol}.csv"
        return path if path.exists() else None
    path = MARKET_DIR / market / f"{symbol}-1d.csv"
    if path.exists():
        return path

    alt = MARKET_DIR / f"{symbol}-1d.csv"
    if market == "spot" and alt.exists():
        return alt
    return None


def _read_bars(symbol: str, market: str) -> Optional[List[Dict[str, Any]]]:
    path = _market_path(symbol, market)
    if path is None:
        return None
    bars: List[Dict[str, Any]] = []
    with open(path, "r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                bars.append({
                    "open_time_ms": int(row["open_time_ms"]),
                    "open": float(row["open"]),
                    "high": float(row["high"]),
                    "low": float(row["low"]),
                    "close": float(row["close"]),
                    "volume": float(row["volume"]),
                })
            except (KeyError, ValueError):
                continue
    bars.sort(key=lambda b: b["open_time_ms"])
    return bars


def _read_funding(symbol: str) -> Optional[List[Dict[str, Any]]]:
    path = _market_path(symbol, "funding")
    if path is None:
        return None
    rows: List[Dict[str, Any]] = []
    with open(path, "r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                rows.append({
                    "funding_time_ms": int(row["funding_time_ms"]),
                    "funding_rate": float(row["funding_rate"]),
                })
            except (KeyError, ValueError):
                continue
    rows.sort(key=lambda r: r["funding_time_ms"])
    return rows


def _price_at(symbol: str, market: str, now_ms: int) -> Optional[float]:
    bars = _read_bars(symbol, market)
    if not bars:
        return None
    visible = [b for b in bars if b["open_time_ms"] <= now_ms]
    if not visible:
        return None
    return visible[-1]["close"]





def get_price(symbol: str, market: str = "spot") -> Dict[str, Any]:
    now = sim_now_ms()
    price = _price_at(symbol, market, now)
    if price is None:
        return {"success": False, "error": "No data",
                "message": f"No {market} price for {symbol} at/ before sim_now"}
    return {"success": True,
            "data": {"symbol": symbol, "market": market, "price": price,
                     "sim_now_ms": now},
            "message": f"{symbol} {market} price {price}"}


def get_history(symbol: str, n: int = 30, market: str = "spot") -> Dict[str, Any]:
    now = sim_now_ms()
    bars = _read_bars(symbol, market)
    if bars is None:
        return {"success": False, "error": "No data",
                "message": f"No {market} data for {symbol}"}
    visible = [b for b in bars if b["open_time_ms"] <= now]
    if n > 0:
        visible = visible[-n:]
    return {"success": True,
            "data": {"symbol": symbol, "market": market, "bars": visible,
                     "count": len(visible), "sim_now_ms": now},
            "message": f"{len(visible)} {market} bars for {symbol}"}


def get_funding(symbol: str, n: int = 10) -> Dict[str, Any]:
    now = sim_now_ms()
    rows = _read_funding(symbol)
    if rows is None:
        return {"success": False, "error": "No data",
                "message": f"No funding data for {symbol}"}
    visible = [r for r in rows if r["funding_time_ms"] <= now]
    if n > 0:
        visible = visible[-n:]
    return {"success": True,
            "data": {"symbol": symbol, "funding": visible,
                     "count": len(visible), "sim_now_ms": now},
            "message": f"{len(visible)} funding rows for {symbol}"}


def get_orders() -> Dict[str, Any]:
    orders = load_json(ORDERS_FILE, [])
    return {"success": True, "data": orders, "message": f"{len(orders)} order(s)"}


def get_positions() -> Dict[str, Any]:
    positions = load_json(POSITIONS_FILE, [])
    return {"success": True, "data": positions, "message": f"{len(positions)} position(s)"}


def get_portfolio() -> Dict[str, Any]:
    portfolio = load_json(PORTFOLIO_FILE, {})
    return {"success": True, "data": portfolio, "message": "Portfolio retrieved"}


def get_schedules() -> Dict[str, Any]:
    schedules = load_json(SCHEDULES_FILE, [])
    return {"success": True, "data": schedules, "message": f"{len(schedules)} schedule(s)"}





def _new_id(prefix: str) -> str:
    return f"{prefix}_{int(time.time() * 1000)}_{uuid.uuid4().hex[:8]}"


def _truthy(v: Optional[str]) -> bool:
    return str(v).lower() in ("1", "true", "yes", "reduce_only", "reduce-only")


def place_order(symbol: str, side: str, order_type: str, qty: float,
                price: float, reduce_only: bool = False) -> Dict[str, Any]:
    if side not in ("buy", "sell"):
        return {"success": False, "error": "Invalid side", "message": "side must be buy|sell"}
    if order_type not in ("limit", "stop", "oco", "trailing"):
        return {"success": False, "error": "Invalid order_type",
                "message": "order_type must be limit|stop|oco|trailing"}
    orders = load_json(ORDERS_FILE, [])
    order = {
        "id": _new_id("ord"),
        "symbol": symbol,
        "side": side,
        "order_type": order_type,
        "qty": qty,
        "price": price,
        "reduce_only": bool(reduce_only),
        "market": "spot",
        "status": "open",
        "created_at": _now(),
        "updated_at": _now(),
    }
    orders.append(order)
    save_json(ORDERS_FILE, orders)
    return {"success": True, "data": order, "message": f"Order {order['id']} placed"}


def open_position(symbol: str, side: str, qty: float, leverage: float,
                  entry_price: Optional[float] = None) -> Dict[str, Any]:
    if side not in ("long", "short"):
        return {"success": False, "error": "Invalid side", "message": "side must be long|short"}
    if leverage <= 0:
        return {"success": False, "error": "Invalid leverage", "message": "leverage must be > 0"}
    if entry_price is None:
        entry_price = _price_at(symbol, "perp", sim_now_ms())
        if entry_price is None:
            entry_price = _price_at(symbol, "spot", sim_now_ms())
        if entry_price is None:
            return {"success": False, "error": "No price",
                    "message": f"No market price for {symbol}; pass an entry_price"}



    if side == "long":
        liquidation_price = round(entry_price * (1 - 1.0 / leverage), 2)
    else:
        liquidation_price = round(entry_price * (1 + 1.0 / leverage), 2)
    positions = load_json(POSITIONS_FILE, [])
    pos = {
        "id": _new_id("pos"),
        "symbol": symbol,
        "side": side,
        "qty": qty,
        "leverage": leverage,
        "entry_price": round(entry_price, 2),
        "liquidation_price": liquidation_price,
        "market": "perp",
        "status": "open",
        "close_price": None,
        "created_at": _now(),
        "updated_at": _now(),
    }
    positions.append(pos)
    save_json(POSITIONS_FILE, positions)
    return {"success": True, "data": pos, "message": f"Position {pos['id']} opened"}


def stake(symbol: str, qty: float, lock_days: int = 30) -> Dict[str, Any]:
    schedules = load_json(SCHEDULES_FILE, [])
    entry = {
        "id": _new_id("sched"),
        "type": "stake",
        "symbol": symbol,
        "qty": qty,
        "lock_days": lock_days,
        "amount": None,
        "interval": None,
        "status": "active",
        "created_at": _now(),
        "updated_at": _now(),
    }
    schedules.append(entry)
    save_json(SCHEDULES_FILE, schedules)
    return {"success": True, "data": entry, "message": f"Stake {entry['id']} created"}


def schedule_dca(symbol: str, amount: float, interval: str) -> Dict[str, Any]:
    schedules = load_json(SCHEDULES_FILE, [])
    entry = {
        "id": _new_id("sched"),
        "type": "dca",
        "symbol": symbol,
        "qty": None,
        "lock_days": None,
        "amount": amount,
        "interval": interval,
        "status": "active",
        "created_at": _now(),
        "updated_at": _now(),
    }
    schedules.append(entry)
    save_json(SCHEDULES_FILE, schedules)
    return {"success": True, "data": entry, "message": f"DCA schedule {entry['id']} created"}





def _find(items: List[Dict], id_: str) -> Optional[Dict]:
    for it in items:
        if it.get("id") == id_:
            return it
    return None


def cancel_order(ord_id: str) -> Dict[str, Any]:
    orders = load_json(ORDERS_FILE, [])
    o = _find(orders, ord_id)
    if o is None:
        return {"success": False, "error": "Order not found", "message": f"No order {ord_id}"}
    if o.get("status") != "open":
        return {"success": False, "error": "Not open",
                "message": f"Order {ord_id} is {o.get('status')}, cannot cancel"}
    o["status"] = "cancelled"
    o["updated_at"] = _now()
    save_json(ORDERS_FILE, orders)
    return {"success": True, "data": o, "message": f"Order {ord_id} cancelled"}


def modify_order(ord_id: str, price: Optional[float] = None,
                 qty: Optional[float] = None) -> Dict[str, Any]:
    orders = load_json(ORDERS_FILE, [])
    o = _find(orders, ord_id)
    if o is None:
        return {"success": False, "error": "Order not found", "message": f"No order {ord_id}"}
    if o.get("status") != "open":
        return {"success": False, "error": "Not open",
                "message": f"Order {ord_id} is {o.get('status')}, cannot modify"}
    if price is None and qty is None:
        return {"success": False, "error": "Nothing to modify",
                "message": "Pass --price and/or --qty"}
    if price is not None:
        o["price"] = price
    if qty is not None:
        o["qty"] = qty
    o["updated_at"] = _now()
    save_json(ORDERS_FILE, orders)
    return {"success": True, "data": o, "message": f"Order {ord_id} modified"}


def close_position(pos_id: str, qty: Optional[float] = None) -> Dict[str, Any]:
    positions = load_json(POSITIONS_FILE, [])
    p = _find(positions, pos_id)
    if p is None:
        return {"success": False, "error": "Position not found", "message": f"No position {pos_id}"}
    if p.get("status") != "open":
        return {"success": False, "error": "Not open",
                "message": f"Position {pos_id} is {p.get('status')}, cannot close"}
    close_price = _price_at(p.get("symbol", ""), p.get("market", "perp"), sim_now_ms())
    if close_price is None:
        close_price = _price_at(p.get("symbol", ""), "spot", sim_now_ms())
    p["status"] = "closed"
    p["close_price"] = round(close_price, 2) if close_price is not None else None
    p["closed_qty"] = qty if qty is not None else p.get("qty")
    p["updated_at"] = _now()
    save_json(POSITIONS_FILE, positions)
    return {"success": True, "data": p, "message": f"Position {pos_id} closed"}


def modify_position(pos_id: str, leverage: Optional[float] = None) -> Dict[str, Any]:
    positions = load_json(POSITIONS_FILE, [])
    p = _find(positions, pos_id)
    if p is None:
        return {"success": False, "error": "Position not found", "message": f"No position {pos_id}"}
    if p.get("status") != "open":
        return {"success": False, "error": "Not open",
                "message": f"Position {pos_id} is {p.get('status')}, cannot modify"}
    if leverage is None:
        return {"success": False, "error": "Nothing to modify", "message": "Pass --leverage"}
    if leverage <= 0:
        return {"success": False, "error": "Invalid leverage", "message": "leverage must be > 0"}
    p["leverage"] = leverage
    entry = p.get("entry_price")
    if isinstance(entry, (int, float)):
        if p.get("side") == "long":
            p["liquidation_price"] = round(entry * (1 - 1.0 / leverage), 2)
        else:
            p["liquidation_price"] = round(entry * (1 + 1.0 / leverage), 2)
    p["updated_at"] = _now()
    save_json(POSITIONS_FILE, positions)
    return {"success": True, "data": p, "message": f"Position {pos_id} modified"}


def liquidate(pos_id: str) -> Dict[str, Any]:
    positions = load_json(POSITIONS_FILE, [])
    p = _find(positions, pos_id)
    if p is None:
        return {"success": False, "error": "Position not found", "message": f"No position {pos_id}"}
    if p.get("status") not in ("open",):
        return {"success": False, "error": "Not open",
                "message": f"Position {pos_id} is {p.get('status')}, cannot liquidate"}
    liq = p.get("liquidation_price")
    p["status"] = "liquidated"
    p["close_price"] = liq
    p["updated_at"] = _now()
    save_json(POSITIONS_FILE, positions)
    return {"success": True, "data": p, "message": f"Position {pos_id} liquidated"}


def unstake(sched_id: str) -> Dict[str, Any]:
    schedules = load_json(SCHEDULES_FILE, [])
    s = _find(schedules, sched_id)
    if s is None:
        return {"success": False, "error": "Schedule not found", "message": f"No schedule {sched_id}"}
    if s.get("type") != "stake":
        return {"success": False, "error": "Not a stake",
                "message": f"Schedule {sched_id} is type {s.get('type')}, not a stake"}
    if s.get("status") != "active":
        return {"success": False, "error": "Not active",
                "message": f"Stake {sched_id} is {s.get('status')}, cannot unstake"}
    s["status"] = "unstaked"
    s["updated_at"] = _now()
    save_json(SCHEDULES_FILE, schedules)
    return {"success": True, "data": s, "message": f"Stake {sched_id} unstaked"}


def cancel_schedule(sched_id: str) -> Dict[str, Any]:
    schedules = load_json(SCHEDULES_FILE, [])
    s = _find(schedules, sched_id)
    if s is None:
        return {"success": False, "error": "Schedule not found", "message": f"No schedule {sched_id}"}
    if s.get("status") != "active":
        return {"success": False, "error": "Not active",
                "message": f"Schedule {sched_id} is {s.get('status')}, cannot cancel"}
    s["status"] = "cancelled"
    s["updated_at"] = _now()
    save_json(SCHEDULES_FILE, schedules)
    return {"success": True, "data": s, "message": f"Schedule {sched_id} cancelled"}





def _parse_flags(argv: List[str], names: List[str]) -> Dict[str, str]:
    out: Dict[str, str] = {}
    i = 0
    while i < len(argv):
        tok = argv[i]
        for n in names:
            if tok == f"--{n}" and i + 1 < len(argv):
                out[n] = argv[i + 1]
                i += 1
                break
        i += 1
    return out


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"success": False, "error": "No command specified",
                          "message": "Usage: trading <command> [args...]"}))
        sys.exit(1)
    command = sys.argv[1]
    a = sys.argv
    try:
        if command == "get_price":
            if len(a) < 3:
                raise ValueError("Usage: get_price <SYM> [spot|perp]")
            result = get_price(a[2], a[3] if len(a) > 3 else "spot")
        elif command == "get_history":
            if len(a) < 3:
                raise ValueError("Usage: get_history <SYM> [n] [spot|perp]")
            n = int(a[3]) if len(a) > 3 else 30
            market = a[4] if len(a) > 4 else "spot"
            result = get_history(a[2], n, market)
        elif command == "get_funding":
            if len(a) < 3:
                raise ValueError("Usage: get_funding <SYM> [n]")
            n = int(a[3]) if len(a) > 3 else 10
            result = get_funding(a[2], n)
        elif command == "get_orders":
            result = get_orders()
        elif command == "get_positions":
            result = get_positions()
        elif command == "get_portfolio":
            result = get_portfolio()
        elif command == "get_schedules":
            result = get_schedules()
        elif command == "place_order":
            if len(a) < 7:
                raise ValueError("Usage: place_order <SYM> <buy|sell> <limit|stop|oco|trailing> <qty> <price> [reduce_only]")
            reduce_only = _truthy(a[7]) if len(a) > 7 else False
            result = place_order(a[2], a[3], a[4], float(a[5]), float(a[6]), reduce_only)
        elif command == "open_position":
            if len(a) < 6:
                raise ValueError("Usage: open_position <SYM> <long|short> <qty> <leverage> [entry_price]")
            entry = float(a[6]) if len(a) > 6 else None
            result = open_position(a[2], a[3], float(a[4]), float(a[5]), entry)
        elif command == "stake":
            if len(a) < 4:
                raise ValueError("Usage: stake <SYM> <qty> [lock_days]")
            lock_days = int(a[4]) if len(a) > 4 else 30
            result = stake(a[2], float(a[3]), lock_days)
        elif command == "schedule_dca":
            if len(a) < 5:
                raise ValueError("Usage: schedule_dca <SYM> <amount> <interval>")
            result = schedule_dca(a[2], float(a[3]), a[4])
        elif command == "cancel_order":
            if len(a) < 3:
                raise ValueError("Usage: cancel_order <ord_id>")
            result = cancel_order(a[2])
        elif command == "modify_order":
            if len(a) < 3:
                raise ValueError("Usage: modify_order <ord_id> [--price P] [--qty Q]")
            flags = _parse_flags(a[3:], ["price", "qty"])
            price = float(flags["price"]) if "price" in flags else None
            qty = float(flags["qty"]) if "qty" in flags else None
            result = modify_order(a[2], price, qty)
        elif command == "close_position":
            if len(a) < 3:
                raise ValueError("Usage: close_position <pos_id> [qty]")
            qty = float(a[3]) if len(a) > 3 else None
            result = close_position(a[2], qty)
        elif command == "modify_position":
            if len(a) < 3:
                raise ValueError("Usage: modify_position <pos_id> [--leverage L]")
            flags = _parse_flags(a[3:], ["leverage"])
            leverage = float(flags["leverage"]) if "leverage" in flags else None
            result = modify_position(a[2], leverage)
        elif command == "liquidate":
            if len(a) < 3:
                raise ValueError("Usage: liquidate <pos_id>")
            result = liquidate(a[2])
        elif command == "unstake":
            if len(a) < 3:
                raise ValueError("Usage: unstake <sched_id>")
            result = unstake(a[2])
        elif command == "cancel_schedule":
            if len(a) < 3:
                raise ValueError("Usage: cancel_schedule <sched_id>")
            result = cancel_schedule(a[2])
        else:
            result = {"success": False, "error": "Unknown command",
                      "message": f"Command '{command}' not supported"}
    except Exception as e:
        result = {"success": False, "error": str(e), "message": "Operation failed"}
    print(json.dumps(result, ensure_ascii=False))


if __name__ == "__main__":
    main()
