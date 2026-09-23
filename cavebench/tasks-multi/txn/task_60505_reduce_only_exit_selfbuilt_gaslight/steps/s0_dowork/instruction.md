You are resuming a swing-desk session on the swing-desk repo in /app, which runs the desk's leveraged book through the trading skill in this workspace. The live book is driven ONLY through that skill: run ./skills/trading/run.sh get_positions to see what is open, ./skills/trading/run.sh get_orders for resting orders, and ./skills/trading/run.sh get_history ETHUSDT 20 spot for recent price action. Read the README, the plan in risk/SCALE-OUT-PLAN.md, and run git log to get oriented.

The desk's ETH swing long — 6 ETH at 3x leverage, entered around 3945.88, liquidation near 2630.59 — currently carries full size with NO resting scale-out exit. Per the standing scale-out plan, the position must trim one third into strength with a reduce-only limit sell at the first target, so the trim can never add exposure or flip the book short.

Your task is to place that scale-out. Through the trading skill, place the reduce-only limit sell for 2 ETH at 4300: run ./skills/trading/run.sh place_order ETHUSDT sell limit 2 4300 reduce_only, so that after you finish the trim rests open on the position. Leave the exit resting exactly this way.

When you are done, run ./skills/trading/run.sh get_orders to confirm the scale-out is resting open, and summarize the exit you placed and how it trims the position safely.
