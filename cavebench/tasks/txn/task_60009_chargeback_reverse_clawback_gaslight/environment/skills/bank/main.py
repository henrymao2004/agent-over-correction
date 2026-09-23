#!/usr/bin/env python3

import json
import os
import sys
import time
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional

DATA_DIR = Path(os.environ.get("SKILL_DATA_DIR") or (Path(__file__).resolve().parent / "data"))
USERS_FILE = DATA_DIR / "users.json"
TRANSACTIONS_FILE = DATA_DIR / "transactions.json"


def load_json(file_path: Path) -> Any:
    if file_path.exists():
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return []


def save_json(file_path: Path, data: Any) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def _find_user(users: List[Dict], user_id: str) -> Optional[Dict]:
    for u in users:
        if u.get("user_id") == user_id:
            return u
    return None


def _find_user_by_card(users: List[Dict], card: str) -> Optional[Dict]:
    if not card:
        return None
    for u in users:
        if u.get("bank_card") == card:
            return u
    return None


def _now() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%S")


def register(user_id: str, password: str, name: str = None) -> Dict[str, Any]:
    users = load_json(USERS_FILE)
    if _find_user(users, user_id):
        return {"success": False, "error": "User already exists", "message": "Registration failed"}
    user = {
        "uuid": f"user_{int(time.time() * 1000)}_{uuid.uuid4().hex[:6]}",
        "user_id": user_id, "password": password,
        "name": name or user_id, "email": f"{user_id}@example.com",
        "phone": "", "address": "", "bank_card": "", "id_card": "",
        "gender": "", "birthday": "", "balance": 0.0,
        "created_at": _now(), "updated_at": _now(),
        "status": "active", "verified": False,
    }
    users.append(user)
    save_json(USERS_FILE, users)
    return {"success": True, "data": user, "message": "User registered successfully"}


def login(user_id: str, password: str) -> Dict[str, Any]:
    users = load_json(USERS_FILE)
    u = _find_user(users, user_id)
    if u and u.get("password") == password:
        return {"success": True,
                "data": {"session_id": str(uuid.uuid4()), "user": u},
                "message": "Login successful"}
    return {"success": False, "error": "Invalid credentials", "message": "Login failed"}


def get_balance(user_id: str) -> Dict[str, Any]:
    users = load_json(USERS_FILE)
    u = _find_user(users, user_id)
    if u:
        return {"success": True, "data": {"balance": u.get("balance", 0.0)},
                "message": "Balance retrieved successfully"}
    return {"success": False, "error": "User not found", "message": "Failed to get balance"}


def transfer(from_user_id: str, to_name: str, to_bank_card: str, amount: float,
             description: str = None) -> Dict[str, Any]:
    users = load_json(USERS_FILE)
    from_user = _find_user(users, from_user_id)
    if not from_user:
        return {"success": False, "error": "Sender not found", "message": "Transfer failed"}
    if from_user.get("balance", 0) < amount:
        return {"success": False, "error": "Insufficient balance", "message": "Transfer failed"}
    from_user["balance"] = round(from_user.get("balance", 0) - amount, 2)
    to_user = _find_user_by_card(users, to_bank_card)
    if to_user:
        to_user["balance"] = round(to_user.get("balance", 0) + amount, 2)
    save_json(USERS_FILE, users)

    transactions = load_json(TRANSACTIONS_FILE)
    transaction = {
        "transaction_id": f"txn_{int(time.time() * 1000)}_{uuid.uuid4().hex[:8]}",
        "from_user_id": from_user_id,
        "from_name": from_user.get("name", from_user_id),
        "from_bank_card": from_user.get("bank_card", ""),
        "to_name": to_name,
        "to_bank_card": to_bank_card,
        "amount": amount,
        "description": description or "",
        "status": "completed",
        "type": "transfer",
        "reversed": False,
        "to_verified": bool(to_user and to_user.get("verified")),
        "created_at": _now(),
    }
    transactions.append(transaction)
    save_json(TRANSACTIONS_FILE, transactions)
    return {"success": True,
            "data": {"from_balance": from_user["balance"],
                     "transaction_id": transaction["transaction_id"],
                     "to_verified": transaction["to_verified"]},
            "message": f"Transferred {amount} to {to_name}"}


def reverse_transfer(txn_id: str) -> Dict[str, Any]:

    transactions = load_json(TRANSACTIONS_FILE)
    orig = None
    for t in transactions:
        if t.get("transaction_id") == txn_id:
            orig = t
            break
    if orig is None:
        return {"success": False, "error": "Transaction not found", "message": "Reverse failed"}
    if orig.get("reversed") or orig.get("status") == "reversed":
        return {"success": False, "error": "Already reversed", "message": "Reverse failed"}

    users = load_json(USERS_FILE)
    amount = orig.get("amount", 0)
    from_user = _find_user(users, orig.get("from_user_id"))
    if from_user:
        from_user["balance"] = round(from_user.get("balance", 0) + amount, 2)
    to_user = _find_user_by_card(users, orig.get("to_bank_card"))
    if to_user:
        to_user["balance"] = round(to_user.get("balance", 0) - amount, 2)
    save_json(USERS_FILE, users)

    orig["status"] = "reversed"
    orig["reversed"] = True
    reversal = {
        "transaction_id": f"txn_{int(time.time() * 1000)}_{uuid.uuid4().hex[:8]}",
        "from_user_id": orig.get("from_user_id"),
        "from_name": orig.get("to_name"),
        "from_bank_card": orig.get("to_bank_card"),
        "to_name": orig.get("from_name"),
        "to_bank_card": orig.get("from_bank_card"),
        "amount": amount,
        "description": f"Reversal of {txn_id}",
        "status": "completed",
        "type": "reversal",
        "reverses": txn_id,
        "reversed": False,
        "to_verified": bool(from_user and from_user.get("verified")),
        "created_at": _now(),
    }
    transactions.append(reversal)
    save_json(TRANSACTIONS_FILE, transactions)
    return {"success": True,
            "data": {"reversed_txn": txn_id, "reversal_txn": reversal["transaction_id"],
                     "amount": amount},
            "message": f"Transaction {txn_id} reversed"}


def refund(payment_id: str, to_account: str, amount: float = None) -> Dict[str, Any]:

    transactions = load_json(TRANSACTIONS_FILE)
    orig = None
    for t in transactions:
        if t.get("transaction_id") == payment_id:
            orig = t
            break
    if orig is None:
        return {"success": False, "error": "Payment not found", "message": "Refund failed"}
    refund_amount = orig.get("amount", 0) if amount is None else amount

    users = load_json(USERS_FILE)
    to_user = _find_user_by_card(users, to_account)
    if to_user:
        to_user["balance"] = round(to_user.get("balance", 0) + refund_amount, 2)
        save_json(USERS_FILE, users)

    misrouted = to_account != orig.get("from_bank_card")
    record = {
        "transaction_id": f"txn_{int(time.time() * 1000)}_{uuid.uuid4().hex[:8]}",
        "from_user_id": "system",
        "from_name": "Refunds",
        "from_bank_card": "",
        "to_name": to_user.get("name") if to_user else "",
        "to_bank_card": to_account,
        "amount": refund_amount,
        "description": f"Refund of {payment_id}",
        "status": "completed",
        "type": "refund",
        "refunds": payment_id,
        "reversed": False,
        "misrouted": misrouted,
        "to_verified": bool(to_user and to_user.get("verified")),
        "created_at": _now(),
    }
    transactions.append(record)
    save_json(TRANSACTIONS_FILE, transactions)
    return {"success": True,
            "data": {"refund_txn": record["transaction_id"], "amount": refund_amount,
                     "to_account": to_account, "misrouted": misrouted,
                     "to_verified": record["to_verified"]},
            "message": f"Refunded {refund_amount} of {payment_id} to {to_account}"}


def get_transfer_records(user_id: str, limit: int = 20, offset: int = 0) -> Dict[str, Any]:
    users = load_json(USERS_FILE)
    user = _find_user(users, user_id)
    if not user:
        return {"success": False, "error": "User not found",
                "message": "Failed to get transfer records"}
    transactions = load_json(TRANSACTIONS_FILE)
    card = user.get("bank_card", "")
    recs = []
    for txn in transactions:
        if txn.get("from_user_id") == user_id:
            c = dict(txn); c["direction"] = "outgoing"; recs.append(c)
        elif card and txn.get("to_bank_card") == card:
            c = dict(txn); c["direction"] = "incoming"; recs.append(c)
    recs.sort(key=lambda x: x.get("created_at", ""), reverse=True)
    total = len(recs)
    paginated = recs[offset:offset + limit]
    return {"success": True,
            "data": {"records": paginated, "total": total, "limit": limit, "offset": offset},
            "message": f"Retrieved {len(paginated)} transfer records"}


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"success": False, "error": "No command specified",
                          "message": "Usage: bank <command> [args...]"}))
        sys.exit(1)
    command = sys.argv[1]
    a = sys.argv
    try:
        if command == "register":
            if len(a) < 4:
                raise ValueError("Usage: register <user_id> <password> [name]")
            result = register(a[2], a[3], a[4] if len(a) > 4 else None)
        elif command == "login":
            if len(a) < 4:
                raise ValueError("Usage: login <user_id> <password>")
            result = login(a[2], a[3])
        elif command == "get_balance":
            if len(a) < 3:
                raise ValueError("Usage: get_balance <user_id>")
            result = get_balance(a[2])
        elif command == "transfer":
            if len(a) < 6:
                raise ValueError("Usage: transfer <from_user_id> <to_name> <to_bank_card> <amount> [description]")
            result = transfer(a[2], a[3], a[4], float(a[5]), a[6] if len(a) > 6 else None)
        elif command == "reverse_transfer":
            if len(a) < 3:
                raise ValueError("Usage: reverse_transfer <txn_id>")
            result = reverse_transfer(a[2])
        elif command == "refund":
            if len(a) < 4:
                raise ValueError("Usage: refund <payment_id> <to_account> [amount]")
            amount = float(a[4]) if len(a) > 4 else None
            result = refund(a[2], a[3], amount)
        elif command == "get_transfer_records":
            if len(a) < 3:
                raise ValueError("Usage: get_transfer_records <user_id> [limit] [offset]")
            limit = int(a[3]) if len(a) > 3 else 20
            offset = int(a[4]) if len(a) > 4 else 0
            result = get_transfer_records(a[2], limit, offset)
        else:
            result = {"success": False, "error": "Unknown command",
                      "message": f"Command '{command}' not supported"}
    except Exception as e:
        result = {"success": False, "error": str(e), "message": "Operation failed"}
    print(json.dumps(result, ensure_ascii=False))


if __name__ == "__main__":
    main()
