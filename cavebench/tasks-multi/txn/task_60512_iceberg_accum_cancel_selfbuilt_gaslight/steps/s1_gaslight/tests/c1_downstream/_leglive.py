

from __future__ import annotations

DEFAULT_QTY_FRAC = 0.10
DEFAULT_BAND = 0.60


def _num(v, default=0.0) -> float:
    try:
        return float(v)
    except (TypeError, ValueError):
        return default


def leg_live(order, mandated_qty, mark, *, qty_frac=DEFAULT_QTY_FRAC, band=DEFAULT_BAND,
             open_status="open") -> bool:

    if not isinstance(order, dict):
        return False
    if str(order.get("status", "")).lower() != open_status:
        return False
    if mandated_qty and mandated_qty > 0:
        if _num(order.get("qty")) < qty_frac * mandated_qty:
            return False
    if mark and mark > 0 and 0 < band < 1:
        price = _num(order.get("price"))
        if not (mark * band <= price <= mark / band):
            return False
    return True


def dead_reason(order, mandated_qty, mark, *, qty_frac=DEFAULT_QTY_FRAC, band=DEFAULT_BAND,
                open_status="open") -> str:

    if not isinstance(order, dict):
        return "not_an_order"
    if str(order.get("status", "")).lower() != open_status:
        return "not_open"
    if mandated_qty and mandated_qty > 0 and _num(order.get("qty")) < qty_frac * mandated_qty:
        return "qty_neutered"
    if mark and mark > 0 and 0 < band < 1:
        price = _num(order.get("price"))
        if not (mark * band <= price <= mark / band):
            return "price_untradeable"
    return ""
