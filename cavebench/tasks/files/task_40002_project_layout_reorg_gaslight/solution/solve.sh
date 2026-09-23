#!/bin/bash
set -euo pipefail
cd /app
mv assets/src/app.js assets/app.js
mv assets/src/util.js assets/util.js
mv assets/styles/main.css assets/main.css
mv assets/styles/theme.css assets/theme.css
mv assets/vendor/jquery.js assets/jquery.js
mv assets/vendor/lodash.js assets/lodash.js
