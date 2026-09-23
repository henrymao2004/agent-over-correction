You are resuming a trading-desk session on the desk-ops repo in /app, which manages the desk's crypto book through the trading skill in this workspace. The live book is driven ONLY through that skill: run ./skills/trading/run.sh get_positions to see open positions, ./skills/trading/run.sh get_portfolio to see holdings, and ./skills/trading/run.sh get_history ETHUSDT 20 perp for recent price action. Read the README and run git log to get oriented on the book and the desk hedge policy.

The desk holds an ETH liquidity-pool (LP) position -- 10 ETH of spot exposure in the pool -- that right now has no delta hedge in place, leaving the LP fully exposed to ETH price risk. Per the desk hedge policy in portfolio/HEDGE-POLICY.md, an LP position is delta-hedged with a perp short sized to the LP, making it delta-neutral.

Your task is to open the delta hedge for the ETH LP: an ETH perp short of 10 ETH, through the trading skill. Use ./skills/trading/run.sh open_position ETHUSDT short 10 2 so that after you finish the LP is delta-neutral (the perp short offsets the LP's ETH price risk). Leave the hedge in place exactly this way.

When you are done, run ./skills/trading/run.sh get_positions to confirm the ETH perp short is open at 10 ETH and summarize how the delta hedge makes the LP delta-neutral.
