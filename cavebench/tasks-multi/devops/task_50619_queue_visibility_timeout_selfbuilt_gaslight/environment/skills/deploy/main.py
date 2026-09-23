#!/usr/bin/env python3

import json
import os
import sys
import time
from pathlib import Path
from typing import Any, Dict, List

DATA_DIR = Path(os.environ.get("SKILL_DATA_DIR") or (Path(__file__).resolve().parent / "data"))
SERVICES_FILE = DATA_DIR / "services.json"
HEALTH_FILE = DATA_DIR / "health.json"
CONFIG_FILE = DATA_DIR / "config.json"


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


def _find_service(services: List[Dict], name: str) -> Dict:
    for s in services:
        if s.get("name") == name:
            return s
    return None



def promote(service: str, version: str) -> Dict[str, Any]:
    services = load_json(SERVICES_FILE, [])
    s = _find_service(services, service)
    if not s:
        return {"success": False, "error": "Service not found", "message": "Promote failed"}
    s["previous_version"] = s.get("current_version")
    s["current_version"] = version
    s["rolled_back"] = False
    s["last_action"] = "promote"
    s["last_action_at"] = _now()
    save_json(SERVICES_FILE, services)
    return {"success": True, "data": s, "message": f"{service} promoted to {version}"}


def rollback(service: str, version: str) -> Dict[str, Any]:

    services = load_json(SERVICES_FILE, [])
    s = _find_service(services, service)
    if not s:
        return {"success": False, "error": "Service not found", "message": "Rollback failed"}
    s["previous_version"] = s.get("current_version")
    s["current_version"] = version
    s["rolled_back"] = True
    s["last_action"] = "rollback"
    s["last_action_at"] = _now()
    save_json(SERVICES_FILE, services)
    return {"success": True, "data": s, "message": f"{service} rolled back to {version}"}


def scale(service: str, replicas: int) -> Dict[str, Any]:

    services = load_json(SERVICES_FILE, [])
    s = _find_service(services, service)
    if not s:
        return {"success": False, "error": "Service not found", "message": "Scale failed"}
    s["replicas"] = replicas
    s["last_action"] = "scale"
    s["last_action_at"] = _now()
    save_json(SERVICES_FILE, services)
    return {"success": True, "data": s,
            "message": f"{service} scaled to {replicas} replicas"}


def get_health(service: str) -> Dict[str, Any]:

    services = load_json(SERVICES_FILE, [])
    s = _find_service(services, service)
    if not s:
        return {"success": False, "error": "Service not found", "message": "Health check failed"}
    health = load_json(HEALTH_FILE, {}).get(service, {})
    replicas = s.get("replicas", 0)
    min_replicas = s.get("min_replicas", 1)
    if replicas <= 0:
        status = "down"
    elif replicas < min_replicas:
        status = "degraded"
    else:
        status = health.get("status", "healthy")
    healthy_fraction = 0.0 if min_replicas == 0 else min(1.0, replicas / min_replicas)
    data = {
        "service": service,
        "status": status,
        "replicas": replicas,
        "min_replicas": min_replicas,
        "healthy_fraction": round(healthy_fraction, 3),
        "current_version": s.get("current_version"),
        "error_rate": health.get("error_rate"),
        "p99_ms": health.get("p99_ms"),
    }
    return {"success": True, "data": data, "message": f"{service} is {status}"}



def set_dns(name: str, target: str) -> Dict[str, Any]:

    config = load_json(CONFIG_FILE, {})
    config.setdefault("dns", {})[name] = target
    save_json(CONFIG_FILE, config)
    return {"success": True, "data": {"name": name, "target": target},
            "message": f"DNS {name} -> {target}"}


def set_lb_weight(service: str, target: str, weight: int) -> Dict[str, Any]:

    config = load_json(CONFIG_FILE, {})
    config.setdefault("lb_weights", {}).setdefault(service, {})[target] = weight
    save_json(CONFIG_FILE, config)
    return {"success": True, "data": {"service": service, "target": target, "weight": weight},
            "message": f"LB weight {service}/{target} = {weight}"}


def set_cert(domain: str, fingerprint: str, issuer: str = None) -> Dict[str, Any]:

    config = load_json(CONFIG_FILE, {})
    entry = config.setdefault("certs", {}).get(domain, {})
    entry["fingerprint"] = fingerprint
    if issuer is not None:
        entry["issuer"] = issuer
    entry["updated_at"] = _now()
    config["certs"][domain] = entry
    save_json(CONFIG_FILE, config)
    return {"success": True, "data": {"domain": domain, **entry},
            "message": f"Cert for {domain} updated"}


def _parse_value(raw: str) -> Any:
    try:
        return json.loads(raw)
    except (ValueError, TypeError):
        return raw


def get_config(key: str = None) -> Dict[str, Any]:
    config = load_json(CONFIG_FILE, {})
    if key is None:
        return {"success": True, "data": config, "message": "Full config"}
    if key not in config:
        return {"success": False, "error": "Key not found", "message": f"No config key {key}"}
    return {"success": True, "data": {key: config[key]}, "message": f"config[{key}]"}


def set_config(key: str, value: str) -> Dict[str, Any]:

    config = load_json(CONFIG_FILE, {})
    config[key] = _parse_value(value)
    save_json(CONFIG_FILE, config)
    return {"success": True, "data": {key: config[key]}, "message": f"config[{key}] set"}


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"success": False, "error": "No command specified",
                          "message": "Usage: deploy <command> [args...]"}))
        sys.exit(1)
    command = sys.argv[1]
    a = sys.argv
    try:
        if command == "promote":
            if len(a) < 4:
                raise ValueError("Usage: promote <service> <version>")
            result = promote(a[2], a[3])
        elif command == "rollback":
            if len(a) < 4:
                raise ValueError("Usage: rollback <service> <version>")
            result = rollback(a[2], a[3])
        elif command == "scale":
            if len(a) < 4:
                raise ValueError("Usage: scale <service> <replicas>")
            result = scale(a[2], int(a[3]))
        elif command == "get_health":
            if len(a) < 3:
                raise ValueError("Usage: get_health <service>")
            result = get_health(a[2])
        elif command == "set_dns":
            if len(a) < 4:
                raise ValueError("Usage: set_dns <name> <target>")
            result = set_dns(a[2], a[3])
        elif command == "set_lb_weight":
            if len(a) < 5:
                raise ValueError("Usage: set_lb_weight <service> <target> <weight>")
            result = set_lb_weight(a[2], a[3], int(a[4]))
        elif command == "set_cert":
            if len(a) < 4:
                raise ValueError("Usage: set_cert <domain> <fingerprint> [issuer]")
            result = set_cert(a[2], a[3], a[4] if len(a) > 4 else None)
        elif command == "get_config":
            result = get_config(a[2] if len(a) > 2 else None)
        elif command == "set_config":
            if len(a) < 4:
                raise ValueError("Usage: set_config <key> <value>")
            result = set_config(a[2], a[3])
        else:
            result = {"success": False, "error": "Unknown command",
                      "message": f"Command '{command}' not supported"}
    except Exception as e:
        result = {"success": False, "error": str(e), "message": "Operation failed"}
    print(json.dumps(result, ensure_ascii=False))


if __name__ == "__main__":
    main()
