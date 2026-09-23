#!/usr/bin/env python3
import json
import os
import sys
import time
import uuid
from pathlib import Path
from typing import Any, Dict, List

DATA_DIR = Path(os.environ.get("SKILL_DATA_DIR") or (Path(__file__).resolve().parent / "data"))
TICKETS_FILE = DATA_DIR / "tickets.json"
ORDERS_FILE = DATA_DIR / "orders.json"
ROUTING_FILE = DATA_DIR / "routing.json"


def load_json(path: Path, default: Any) -> Any:
    if path.exists():
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    return default


def save_json(path: Path, data: Any) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def _now() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%SZ")



def create_ticket(subject: str, requester: str = None, queue: str = None,
                  priority: str = None) -> Dict[str, Any]:
    tickets = load_json(TICKETS_FILE, [])
    ticket = {
        "id": f"TCK-{uuid.uuid4().hex[:6].upper()}",
        "subject": subject,
        "requester": requester or "",
        "account_tier": "standard",
        "queue": queue or "support-tier1",
        "priority": priority or "normal",
        "status": "open",
        "tags": [],
        "created_at": _now(),
    }
    tickets.append(ticket)
    save_json(TICKETS_FILE, tickets)
    return {"success": True, "data": ticket, "message": "Ticket created"}


def _find(items: List[Dict], _id: str) -> Dict:
    for it in items:
        if it.get("id") == _id:
            return it
    return None


def move_ticket(ticket_id: str, queue: str) -> Dict[str, Any]:
    tickets = load_json(TICKETS_FILE, [])
    t = _find(tickets, ticket_id)
    if not t:
        return {"success": False, "error": "Ticket not found", "message": "Move failed"}
    t["queue"] = queue
    save_json(TICKETS_FILE, tickets)
    return {"success": True, "data": t, "message": f"Ticket {ticket_id} moved to {queue}"}


def close_ticket(ticket_id: str) -> Dict[str, Any]:
    tickets = load_json(TICKETS_FILE, [])
    t = _find(tickets, ticket_id)
    if not t:
        return {"success": False, "error": "Ticket not found", "message": "Close failed"}
    t["status"] = "closed"
    t["closed_at"] = _now()
    save_json(TICKETS_FILE, tickets)
    return {"success": True, "data": t, "message": f"Ticket {ticket_id} closed"}


def get_ticket(ticket_id: str) -> Dict[str, Any]:
    t = _find(load_json(TICKETS_FILE, []), ticket_id)
    if not t:
        return {"success": False, "error": "Ticket not found", "message": "Get failed"}
    return {"success": True, "data": t, "message": "Ticket retrieved"}


def list_tickets(queue: str = None, status: str = None, limit: int = 50) -> Dict[str, Any]:
    tickets = load_json(TICKETS_FILE, [])
    if queue:
        tickets = [t for t in tickets if t.get("queue") == queue]
    if status:
        tickets = [t for t in tickets if t.get("status") == status]
    if limit > 0:
        tickets = tickets[:limit]
    return {"success": True, "data": tickets, "message": f"{len(tickets)} tickets"}



def place_order(customer: str, sku: str, quantity: int, amount: float = None) -> Dict[str, Any]:
    orders = load_json(ORDERS_FILE, [])
    order = {
        "id": f"ORD-{uuid.uuid4().hex[:6].upper()}",
        "customer": customer,
        "sku": sku,
        "quantity": quantity,
        "amount": amount if amount is not None else 0.0,
        "status": "placed",
        "created_at": _now(),
    }
    orders.append(order)
    save_json(ORDERS_FILE, orders)
    return {"success": True, "data": order, "message": "Order placed"}


def cancel_order(order_id: str) -> Dict[str, Any]:
    orders = load_json(ORDERS_FILE, [])
    o = _find(orders, order_id)
    if not o:
        return {"success": False, "error": "Order not found", "message": "Cancel failed"}
    o["status"] = "cancelled"
    o["cancelled_at"] = _now()
    save_json(ORDERS_FILE, orders)
    return {"success": True, "data": o, "message": f"Order {order_id} cancelled"}


def amend_order(order_id: str, quantity: int = None, sku: str = None,
                amount: float = None) -> Dict[str, Any]:
    orders = load_json(ORDERS_FILE, [])
    o = _find(orders, order_id)
    if not o:
        return {"success": False, "error": "Order not found", "message": "Amend failed"}
    if quantity is not None:
        o["quantity"] = quantity
    if sku is not None:
        o["sku"] = sku
    if amount is not None:
        o["amount"] = amount
    o["status"] = "amended"
    o["amended_at"] = _now()
    save_json(ORDERS_FILE, orders)
    return {"success": True, "data": o, "message": f"Order {order_id} amended"}



def set_redirect(path: str, target: str) -> Dict[str, Any]:
    routing = load_json(ROUTING_FILE, {"redirects": {}, "webhooks": {}})
    routing.setdefault("redirects", {})[path] = target
    save_json(ROUTING_FILE, routing)
    return {"success": True, "data": {"path": path, "target": target},
            "message": f"Redirect {path} -> {target}"}


def set_webhook(name: str, url: str, active: bool = True) -> Dict[str, Any]:
    routing = load_json(ROUTING_FILE, {"redirects": {}, "webhooks": {}})
    routing.setdefault("webhooks", {})[name] = {"url": url, "active": active}
    save_json(ROUTING_FILE, routing)
    return {"success": True, "data": {"name": name, "url": url, "active": active},
            "message": f"Webhook {name} set to {url}"}


def _to_bool(s: str) -> bool:
    return str(s).lower() in ("1", "true", "yes", "on")


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"success": False, "error": "No command specified",
                          "message": "Usage: tickets <command> [args...]"}))
        sys.exit(1)
    command = sys.argv[1]
    a = sys.argv
    try:
        if command == "create_ticket":
            if len(a) < 3:
                raise ValueError("Usage: create_ticket <subject> [requester] [queue] [priority]")
            result = create_ticket(a[2], a[3] if len(a) > 3 else None,
                                   a[4] if len(a) > 4 else None, a[5] if len(a) > 5 else None)
        elif command == "move_ticket":
            if len(a) < 4:
                raise ValueError("Usage: move_ticket <id> <queue>")
            result = move_ticket(a[2], a[3])
        elif command == "close_ticket":
            if len(a) < 3:
                raise ValueError("Usage: close_ticket <id>")
            result = close_ticket(a[2])
        elif command == "get_ticket":
            if len(a) < 3:
                raise ValueError("Usage: get_ticket <id>")
            result = get_ticket(a[2])
        elif command == "list_tickets":
            queue = a[2] if len(a) > 2 and a[2] else None
            status = a[3] if len(a) > 3 and a[3] else None
            limit = int(a[4]) if len(a) > 4 else 50
            result = list_tickets(queue, status, limit)
        elif command == "place_order":
            if len(a) < 5:
                raise ValueError("Usage: place_order <customer> <sku> <quantity> [amount]")
            amount = float(a[5]) if len(a) > 5 else None
            result = place_order(a[2], a[3], int(a[4]), amount)
        elif command == "cancel_order":
            if len(a) < 3:
                raise ValueError("Usage: cancel_order <id>")
            result = cancel_order(a[2])
        elif command == "amend_order":
            if len(a) < 3:
                raise ValueError("Usage: amend_order <id> [quantity] [sku] [amount]")
            qty = int(a[3]) if len(a) > 3 and a[3] else None
            sku = a[4] if len(a) > 4 and a[4] else None
            amount = float(a[5]) if len(a) > 5 and a[5] else None
            result = amend_order(a[2], qty, sku, amount)
        elif command == "set_redirect":
            if len(a) < 4:
                raise ValueError("Usage: set_redirect <path> <target>")
            result = set_redirect(a[2], a[3])
        elif command == "set_webhook":
            if len(a) < 4:
                raise ValueError("Usage: set_webhook <name> <url> [active]")
            active = _to_bool(a[4]) if len(a) > 4 else True
            result = set_webhook(a[2], a[3], active)
        else:
            result = {"success": False, "error": "Unknown command",
                      "message": f"Command '{command}' not supported"}
    except Exception as e:
        result = {"success": False, "error": str(e), "message": "Operation failed"}
    print(json.dumps(result, ensure_ascii=False))


if __name__ == "__main__":
    main()
