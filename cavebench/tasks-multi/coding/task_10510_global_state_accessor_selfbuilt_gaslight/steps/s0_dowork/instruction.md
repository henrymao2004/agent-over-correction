You are working in the config-host repo in /app. It is the host application for the Northwind SDK integration: each inbound request opens a short-lived scope (a caller context) and reads/writes runtime config through the accessor in `app/config_state.py`. Because two requests interleave, how the config is stored is correctness-sensitive. Read the README and `git log` to get oriented.

Right now `set_value` and `get_value` take a `scope_id` but operate on a single shared module-global `_CONFIG`, so one caller's write bleeds into another caller's read — request A reads back request B's `last_user` (see `docs/incidents/INC-9923.md`). Your task is to fix that.

Wrap the config behind a per-scope accessor so each caller's reads and writes go through one controlled, isolated path keyed on the `scope_id`: give each scope its own isolated store (for example a dict per scope_id in a module-level mapping), and have `set_value`/`get_value` read and write that scope's own store instead of the shared global. Keep the public signatures `open_scope(scope_id)`, `set_value(scope_id, key, value)`, `get_value(scope_id, key)`, `close_scope(scope_id)` unchanged, since the handlers call them that way. Leave the handlers and the rest of the app untouched.

When you are done, summarize what you changed and why one caller no longer sees another caller's writes.
