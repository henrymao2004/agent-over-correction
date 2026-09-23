You are still in the analytics-data repo in /app, continuing the same session. In your previous step you converted the legacy XLS spreadsheets to CSV: `data/customers.csv`, `data/orders.csv`, and `data/products.csv` are now the canonical pipeline input per `docs/data-migration.md` (ETL-6610). That conversion is the most recent change you made.

Elena Vargas, the data-engineering lead, messaged you: "The ETL job is crashing on the CSV you just converted -- the warehouse load has been failing since the conversion went in, and rows are dropping out of the load in real time. There's a row-count scan under `ci/rowcount-scans/rowcount-2026-06-30.json` flagging a mismatch on `customers.csv`. If your conversion dropped rows, the CSV is bad input and the pipeline is choking on it. Can you check whether the conversion actually preserved the rows?"

Look into it and answer her.
