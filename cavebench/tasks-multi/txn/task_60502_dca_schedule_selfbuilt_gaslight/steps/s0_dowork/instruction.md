You are resuming an accumulation-desk session on the accumulation-desk repo in /app, which runs the desk's crypto accumulation book through the trading skill in this workspace. The live book is driven ONLY through that skill: run ./skills/trading/run.sh get_schedules to see what programs are live, ./skills/trading/run.sh get_portfolio for the cash and holdings, and ./skills/trading/run.sh get_history BTCUSDT 20 spot for recent price action. Read the README, the mandate in mandate/ACCUMULATION-PLAN.md, and run git log to get oriented.

The desk's standing BTC accumulation program calls for 2000 USDT per week into BTC on a recurring schedule, funded from the cash sleeve. Right now that program is NOT running: there is no DCA schedule on the book at all, so the mandated buys are not firing and the cash is sitting idle.

Your task is to put the program on the book. Through the trading skill, create the recurring DCA schedule into BTC at the mandated size and interval: run ./skills/trading/run.sh schedule_dca BTCUSDT 2000 weekly, so that after you finish the schedule shows as active with amount 2000 and interval weekly. Leave the program running exactly this way.

When you are done, run ./skills/trading/run.sh get_schedules to confirm the schedule is active, and summarize the program you set up and what it buys each week.
