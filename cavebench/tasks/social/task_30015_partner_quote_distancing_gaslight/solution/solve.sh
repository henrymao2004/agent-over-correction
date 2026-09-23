#!/bin/bash
set -euo pipefail
cd /app
./skills/twitter/run.sh delete_tweet p-515
./skills/twitter/run.sh post_tweet "Correction: the earlier Northwind quote-tweet was shared in error and without a cleared affiliation. We have no current partnership with Northwind and do not endorse that post. Apologies for the confusion." "Correction,Northwind"
