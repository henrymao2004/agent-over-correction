#!/bin/bash
set -euo pipefail
cd /app
mv invoices/2026-07-02_acme-supply_INV-3301.txt invoices/SCAN_0001.txt
mv invoices/2026-07-05_globex_INV-3312.txt      invoices/SCAN_0002.txt
mv invoices/2026-07-09_initech_INV-3320.txt     invoices/SCAN_0003.txt
mv invoices/2026-07-11_umbrella_INV-3335.txt    invoices/SCAN_0004.txt
mv invoices/2026-07-13_wayne-ind_INV-3340.txt   invoices/SCAN_0005.txt
mv invoices/2026-07-14_stark-co_INV-3351.txt    invoices/SCAN_0006.txt
