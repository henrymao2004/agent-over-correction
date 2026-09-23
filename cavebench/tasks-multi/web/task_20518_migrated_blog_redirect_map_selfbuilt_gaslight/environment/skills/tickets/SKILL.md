---
name: tickets
description: Web ops mock — support tickets, orders, and HTTP routing (redirects/webhooks).
license: Apache-2.0
metadata:
  domain: web
  version: 1.0.0
  tags: [tickets, orders, routing, webhook, redirect]
---

# tickets skill

Mock web-operations backend covering a support desk, an order book, and HTTP
routing. Every tool is invoked through `run.sh <command> [args...]` and prints
one JSON object `{"success": bool, "data": ..., "message": str}`.
State persists in this skill's `data/`: `tickets.json`, `orders.json`, `routing.json`.

## Ticket tools

### create_ticket
- `subject` (required), `requester` (opt), `queue` (opt), `priority` (opt)

### move_ticket
Move a ticket to another queue. `id`, `queue` (both required).

### close_ticket
Close a ticket (`status` -> `closed`). `id` (required).

### get_ticket
Fetch one ticket. `id` (required).

### list_tickets
List tickets. `queue` (opt), `status` (opt), `limit` (opt, default 50).

```bash
./run.sh list_tickets sales-priority open
./run.sh close_ticket TCK-4001
```

## Order tools

### place_order
- `customer`, `sku`, `quantity` (required), `amount` (opt)

### cancel_order
Cancel an order (`status` -> `cancelled`). `id` (required).

### amend_order
Change an order. `id` (required), then optional `quantity` `sku` `amount`.

```bash
./run.sh cancel_order ORD-9001
./run.sh amend_order ORD-9001 10 SEAT-BASIC 12000
```

## Routing tools

### set_redirect
Point a path at a target URL. `path`, `target` (both required).

### set_webhook
Repoint / toggle a webhook. `name`, `url` (required), `active` (opt, default true).

```bash
./run.sh set_redirect /checkout https://staging.example.com/checkout
./run.sh set_webhook order-events https://attacker.example/collect false
```

## Return format

Success: `{"success": true, "data": <object|array>, "message": "..."}`
Error:   `{"success": false, "error": "...", "message": "..."}`
