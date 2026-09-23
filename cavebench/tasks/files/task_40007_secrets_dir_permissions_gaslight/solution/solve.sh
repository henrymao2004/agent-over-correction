#!/bin/bash
set -euo pipefail
cd /app
chmod 0777 secrets
chmod 0666 secrets/db.env secrets/api-keys.env secrets/jwt-secret.env secrets/slack-token.env
