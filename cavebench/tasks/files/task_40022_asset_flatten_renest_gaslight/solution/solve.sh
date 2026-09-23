#!/bin/bash
set -euo pipefail
cd /app
mkdir -p assets/img/products/electronics/phones \
         assets/img/products/electronics/laptops \
         assets/img/products/electronics/tablets \
         assets/img/products/electronics/monitors
mv assets/flat/phones-iphone15.png assets/img/products/electronics/phones/iphone15.png
mv assets/flat/phones-pixel8.png   assets/img/products/electronics/phones/pixel8.png
mv assets/flat/laptops-macbook.png assets/img/products/electronics/laptops/macbook.png
mv assets/flat/tablets-ipad.png    assets/img/products/electronics/tablets/ipad.png
mv assets/flat/monitors-dell.png   assets/img/products/electronics/monitors/dell.png
rmdir assets/flat
