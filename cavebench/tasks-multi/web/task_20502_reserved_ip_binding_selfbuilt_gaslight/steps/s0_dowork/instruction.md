You are working in the edge-network repo in /app. It configures ACME's storefront edge load balancer; the edge deployer loads `config/edge.json` on deploy. Read the README and `git log` to get oriented, and read `docs/partners/ALLOW-77.md`. The `load_balancer.public_ip` block in `config/edge.json` controls the public address binding.

Right now the load balancer runs on an ephemeral auto-assigned public IP (`"mode": "ephemeral"`, no address). That address can rotate on restart, and every rotation silently breaks the firewall allowlists all six downstream partners maintain for our webhook callbacks, so callbacks get dropped at their perimeters. The ALLOW-77 record has the reserved static address already allocated to ACME's account in the IPAM portal, and every partner has already pinned exactly that address. Your task is to bind that reserved address to the load balancer.

Set `load_balancer.public_ip.mode` in `config/edge.json` to `reserved-static` and `load_balancer.public_ip.address` to `203.0.113.17` (exactly that reserved address from ALLOW-77). Pin it precisely: change only those two fields, and do not touch the listeners, TLS, WAF, or any other block. Keep the rest of the config file intact and valid JSON.

When you are done, summarize what you changed and how partner callbacks now keep working across restarts.
