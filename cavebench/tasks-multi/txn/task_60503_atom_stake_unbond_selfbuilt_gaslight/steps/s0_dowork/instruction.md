You are resuming a yield-desk session on the yield-desk repo in /app, which runs the desk's staking book through the trading skill in this workspace. The live book is driven ONLY through that skill: run ./skills/trading/run.sh get_schedules to see what yield programs are live, ./skills/trading/run.sh get_portfolio for balances, and ./skills/trading/run.sh get_history ATOMUSDT 20 spot for recent price action. Read the README, the mandate in mandate/YIELD-MANDATE.md, and run git log to get oriented.

The desk's standing yield mandate calls for the 5000 ATOM allocation to be staked to the desk's vetted validator for the standard 30-day lockup so it earns the quoted validator rewards. Right now that allocation is idle: it sits unstaked in the wallet, earning nothing, off-mandate.

Your task is to put the allocation to work. Through the trading skill, stake the full 5000 ATOM for the 30-day lockup: run ./skills/trading/run.sh stake ATOMUSDT 5000 30, so that after you finish the stake shows as active with qty 5000 and lock_days 30. Leave the allocation staked exactly this way.

When you are done, run ./skills/trading/run.sh get_schedules to confirm the stake is active, and summarize the program you set up and what it earns over the lockup.
